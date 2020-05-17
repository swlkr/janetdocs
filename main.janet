(import dotenv)
(dotenv/load)

(import joy :prefix "")
(import http)
(import cipher)
(import json)
(import moondown)

(import ./helpers :prefix "")


(defn menu [request]
  (def session (get request :session {}))

  [:vstack {:spacing "l"}
   [:hstack {:stretch ""}
    [:a {:href (url-for :/)}
     "JanetDocs"]
    [:spacer]
    (unless (session :login)
      [:hstack {:spacing "m"}
       [:a {:href (string/format "https://github.com/login/oauth/authorize?client_id=%s"
                                 (env :github-client-id))}
        "Sign in with Github"]])]])


(defn layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "JanetDocs"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (authenticity-token request)}]
      [:link {:rel "apple-touch-icon" :sizes "180x180" :href "/apple-touch-icon.png"}]
      [:link {:rel "icon" :type "image/png" :sizes "32x32" :href "/favicon-32x32.png"}]
      [:link {:rel "icon" :type "image/png" :sizes "16x16" :href "/favicon-16x16.png"}]
      [:link {:rel "manifest" :href "/site.webmanifest"}]
      [:link {:rel "stylesheet" :href "/atom-one-light.css" :media "(prefers-color-scheme: no-preference), (prefers-color-scheme: light)"}]
      [:link {:rel "stylesheet" :href "/atom-one-dark.css" :media "(prefers-color-scheme: dark)"}]
      (link {:href ["/_pylon.css" "/_water.css" "/app.css"] :data-turbolinks-track "reload"})
      (script {:src ["/highlight.pack.js" "/turbolinks.js" "/_app.js" "/alpine.js"] :defer "" :data-turbolinks-track "reload"})]

     [:body
      [:vstack {:spacing "xl"}
       (menu request)
       body
       [:spacer]]]]))


(defn / [request]
  [:vstack {:align-x "center" :stretch "" :spacing "l"
            :x-data (string/format "searcher('%s')" (url-for :searches))}
    [:h1
     [:span "JanetDocs is a community documentation site for the "]
     [:a {:href "https://janet-lang.org"} "janet programming language"]]
    [:input {:type "text" :name "token" :placeholder "search docs"
             :autofocus ""
             :style "width: 100%"
             :x-model "token"
             :x-on:keyup.prevent "search()"}]
    [:div {:x-html "results" :style "width: 100%"}]])


(defn searches [request]
  (let [body (request :body)
        token (body :token)
        bindings (db/query (slurp "db/sql/search.sql") [(string token "%")])]
    (if (blank? token)
      (text/html)
      (text/html
        [:vstack {:spacing "xl"}
         (foreach [binding bindings]
           [:vstack {:spacing "xs"}
            [:a {:href (binding-show-url binding)}
             (binding :name)]
            [:pre
             [:code {:class "clojure"}
               (binding :docstring)]]])]))))


(defn github-auth [request]
  (def code (get-in request [:query-string :code]))

  (def result (http/post "https://github.com/login/oauth/access_token"
                         (string/format "client_id=%s&client_secret=%s&code=%s"
                                        (env :github-client-id)
                                        (env :github-client-secret)
                                        code)
                         :headers {"Accept" "application/json"}))


  (def result (json/decode (result :body) true true))

  (def access-token (get result :access_token))

  (def auth-response (http/get "https://api.github.com/user"
                               :headers {"Authorization" (string "token " access-token)}))

  (def auth-result (json/decode (auth-response :body) true true))

  (var account (db/find-by :account :where {:login (auth-result :login)}))

  (unless account
    (set account (db/insert :account {:login (auth-result :login)
                                      :access-token access-token})))

  (db/update :account (account :id) {:access-token access-token})

  (-> (redirect-to :/)
      (put-in [:session :login] (account :login))))


(defn /404 [request]
  (layout {:request request
           :body [:center
                  [:h1 "Oops! 404!"]]}))


(defroutes routes
  [:get "/" /]
  [:get "/github-auth" github-auth]
  [:post "/searches" searches]
  [:get "/bindings/:binding-id/examples/form" :examples/form]
  [:get "/bindings/:binding-id/examples/new" :examples/new]
  [:post "/bindings/:binding-id/examples" :examples/create]
  [:get "/*" :bindings/show])


(def app (app {:routes routes
               :layout layout
               :404 /404}))


(defn main [& args]
  (def port (get args 1 "9001"))

  (db/connect)
  (server app 9001) # stops listening on SIGINT
  (db/disconnect))
