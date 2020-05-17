(import joy :prefix "")


(defmacro foreach [binding & body]
  ~(map (fn [val]
          (let [,(first binding) val]
            ,;body))
        ,(get binding 1)))


(defn blank? [val]
  (or (nil? val) (empty? val)))


(defn binding-header [binding]
  [:vstack
   [:h1 (binding :name)]
   [:strong (get-in binding [:package :name] (binding :package))]
   [:pre
    [:code {:class "clojure"}
     (binding :docstring)]]])


(defn binding-show-url [binding]
  (def package (db/find :package (or (binding :package-id) 0)))

  (if package
    (string "/" (package :name) "/" (binding :name))
    (string "/" (binding :name))))


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


(defn params [request k &opt val]
  (default val 0)
  (get-in request [:params k] val))
