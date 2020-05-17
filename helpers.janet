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
