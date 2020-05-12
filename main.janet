(use joy)


(defn blank? [val]
  (or (nil? val) (empty? val)))


(defn menu [request]
  [:vstack {:spacing "l"}
   [:hstack {:stretch ""}
    [:a {:href (url-for :home)}
     "JanetDocs"]
    [:spacer]
    [:hstack {:spacing "m"}
     [:a {:href "/join"
          :role "button"}
      "Sign in with Github"]]]])


(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "janetdocs"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (authenticity-token request)}]
      (links {:href ["/_pylon.css" "/_water.css" "/app.css"] :data-turbolinks-track "reload"})
      (scripts {:src ["/turbolinks.js" "/_app.js" "/alpine.js"] :defer "" :data-turbolinks-track "reload"})]
     [:body
      [:vstack {:spacing "xl"}
       (menu request)
       body
       [:spacer]]]]))


(defmacro foreach [binding & body]
  ~(map (fn [val]
          (let [,(first binding) val]
            ,;body))
        ,(get binding 1)))


(defn home [request]
  [:vstack {:align-x "center" :stretch "" :spacing "l" :x-data (string/format "searcher('%s')" (url-for :search))}
    [:h1
     [:span "JanetDocs is a community documentation site for the "]
     [:a {:href "https://janet-lang.org"} "janet programming language"]]
    [:input {:type "text" :name "token" :placeholder "search docs"
             :style "width: 100%"
             :x-model "token"
             :x-on:keyup "search()"}]
    [:div {:x-html "results" :style "width: 100%"}]])


(defn search [request]
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


(defn symbol [request]
  (when-let [name (request :wildcard)
             d (first (db/query (slurp "db/sql/search.sql") [name]))]
    [:vstack
     [:h1 (d :name)]
     [:strong (d :package)]
     [:pre
      [:code
       (d :docstring)]]]))


(defroutes routes
  [:get "/" home]
  [:post "/search" search]
  [:get "/*" symbol])


(defn not-found-fn [request]
  (app-layout {:request request
               :body [:center
                      [:h1 "Oops! 404!"]]}))


(def app (as-> routes ?
               (handler ?)
               (layout ? app-layout)
               (not-found ? not-found-fn)
               (logger ?)
               (csrf-token ?)
               (session ?)
               (extra-methods ?)
               (query-string ?)
               (json-body-parser ?)
               (body-parser ?)
               (server-error ?)
               (x-headers ?)
               (static-files ?)))


(defn main [& args]
  (def port (or (get args 1) (env :port) "8000"))

  (db/connect (env :database-url))
  (server app port) # stops listening on SIGINT
  (db/disconnect))
