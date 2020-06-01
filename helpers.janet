(import joy :prefix "")


(defmacro foreach [binding & body]
  ~(map (fn [val]
          (let [,(first binding) val]
            ,;body))
        ,(get binding 1)))


(defn blank? [val]
  (or (nil? val) (empty? val)))


(defn binding-header [binding]
  [:vstack {:spacing "xs"}
   [:h1 (binding :name)]
   [:strong (get-in binding [:package :name] (binding :package))]
   [:pre
    [:code {:class "clojure"}
     (binding :docstring)]]])


(defn binding-show-url [binding]
  (def package (db/find :package (or (binding :package-id) 0)))

  (def name (string/replace "?" "_q" (binding :name)))

  (if package
    (string "/" (package :name) "/" name)
    (string "/" name)))


(defn pluralize [str n]
  (if (one? n)
    (string/trimr str "s")
    str))


(defn confirm-modal [request & body]
  [:div {:x-data "{ modalOpen: false, action: '' }"}
   body
   [:div {:class "md-modal" ::class "{'md-show': modalOpen}" :x-show "modalOpen" :@click.away "modalOpen = false"}
    [:div {:class "md-content"}
     [:vstack {:align-x "center"}
      [:h3 "Are you sure?"]
      [:hstack {:spacing "l" :align-x "center"}
       (form-with request {:method "POST" :x-bind:action "action"}
         [:input {:type "hidden" :name "_method" :value "DELETE"}]
         [:button {:type "submit"}
          "Yes, do it"])
       [:a {:href "#" :@click.prevent "modalOpen = false"}
        "No"]]]]]
   [:div {:class "md-overlay" ::class "{'md-show': modalOpen}"}]])


(defn delete-button [request action]
  (confirm-modal request
    [:a {:href "#"
         :@click.prevent (string/format "action = '%s'; modalOpen = true" action)}
      "Delete"]))


(defn current-account [request]
  (def login (get-in request [:session :login] ""))
  (db/find-by :account :where {:login login}))


(defn menu [request]
  (def session (get request :session {}))

  [:vstack {:spacing "l"}
   [:hstack {:stretch ""}
    [:a {:href (url-for :home/index)}
     "JanetDocs"]
    [:spacer]
    (if (get session :login)
      [:hstack {:spacing "m"}
       (form-with request (action-for :sessions/destroy)
         [:input {:type "hidden" :name "_method" :value "delete"}]
         [:input {:type "submit" :value "Sign out"}])]

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
      [:link {:rel "stylesheet" :href "/css/atom-one-light.css" :media "(prefers-color-scheme: no-preference), (prefers-color-scheme: light)"}]
      [:link {:rel "stylesheet" :href "/css/atom-one-dark.css" :media "(prefers-color-scheme: dark)"}]
      (link {:href ["/_pylon.css" "/_water.css" "/app.css"] :data-turbolinks-track "reload"})
      [:script {:src "/js/_turbolinks.min.js" :defer "" :data-turbolinks-track "reload"}]
      (script {:src ["/_highlight.pack.js" "/_app.js" "/alpine.min.js"] :defer "" :data-turbolinks-track "reload"})]

     [:body
      [:vstack {:spacing "xl"}
       (menu request)
       body
       [:spacer]]]]))


(defn /404 [request]
  (layout {:request request
           :body [:center
                  [:h1 "Oops! 404!"]]}))
