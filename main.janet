(import dotenv)
(dotenv/load)

(import joy :prefix "")
(import http)
(import cipher)
(import json)


(defmacro foreach [binding & body]
  ~(map (fn [val]
          (let [,(first binding) val]
            ,;body))
        ,(get binding 1)))


(defn blank? [val]
  (or (nil? val) (empty? val)))


(defn menu [request]
  (def session (get request :session {}))

  [:vstack {:spacing "l"}
   [:hstack {:stretch ""}
    [:a {:href (url-for :/)}
     "JanetDocs"]
    [:spacer]
    (unless (session :access-token)
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
      (link {:href ["/_pylon.css" "/_water.css" "/app.css"] :data-turbolinks-track "reload"})
      [:link {:rel "apple-touch-icon" :sizes "180x180" :href "/apple-touch-icon.png"}]
      [:link {:rel "icon" :type "image/png" :sizes "32x32" :href "/favicon-32x32.png"}]
      [:link {:rel "icon" :type "image/png" :sizes "16x16" :href "/favicon-16x16.png"}]
      [:link {:rel "manifest" :href "/site.webmanifest"}]
      (script {:src ["/turbolinks.js" "/_app.js" "/alpine.js"] :defer "" :data-turbolinks-track "reload"})]
     [:body
      [:vstack {:spacing "xl"}
       (menu request)
       body
       [:spacer]]]]))


(defn / [request]
  [:vstack {:align-x "center" :stretch "" :spacing "l" :x-data (string/format "searcher('%s')" (url-for :/search/post))}
    [:h1
     [:span "JanetDocs is a community documentation site for the "]
     [:a {:href "https://janet-lang.org"} "janet programming language"]]
    [:input {:type "text" :name "token" :placeholder "search docs"
             :style "width: 100%"
             :x-model "token"
             :x-on:keyup "search()"}]
    [:div {:x-html "results" :style "width: 100%"}]])


(defn /search/post [request]
  (let [body (request :body)
        token (body :token)
        filtered-docs (db/query (slurp "db/sql/search.sql") [(string token "%")])]
    (if (blank? token)
      (text/html)
      (text/html
        [:vstack {:spacing "xl"}
         (foreach [d filtered-docs]
           [:vstack {:spacing "xs"}
            [:a {:href (string "/" (d :name))}
             (d :name)]
            [:pre
             [:code
               (d :docstring)]]])]))))


(defn /github-auth [request]
  (def code (get-in request [:query-string :code]))

  (def result (http/post "https://github.com/login/oauth/access_token"
                         (string/format "client_id=%s&client_secret=%s&code=%s"
                                        (env :github-client-id)
                                        (env :github-client-secret)
                                        code)
                         :headers {"Accept" "application/json"}))


  (def result (json/decode (result :body) true true))

  (printf "%q" result)

  (def access-token (get result :access_token))

  (def auth-response (http/get "https://api.github.com/user"
                               :headers {"Authorization" (string "token " access-token)}))

  (printf "auth-response %q" auth-response)

  (-> (redirect-to :/)
      (put-in [:session :access-token] access-token)))


(defn /* [request]
  (when-let [name (request :wildcard)
             d (first (db/query (slurp "db/sql/search.sql") [name]))]
    [:vstack
     [:h1 (d :name)]
     [:strong (d :package)]
     [:pre
      [:code
       (d :docstring)]]]))


(defn /404 [request]
  (layout {:request request
           :body [:center
                  [:h1 "Oops! 404!"]]}))


(def app (app {:layout layout
               :404 /404}))


(defn main [& args]
  (def port (get args 1 "9001"))

  (db/connect)
  (server app 9001) # stops listening on SIGINT
  (db/disconnect))
