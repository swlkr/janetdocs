(import joy :prefix "")
(import ../helpers :prefix "")
(import ./examples)


(defn show [request]
  (when-let [name (request :wildcard)
             binding (first (db/query (slurp "db/sql/search.sql") [name]))]

    [:vstack {:spacing "m"}
     (binding-header binding)
     (examples/index (merge request {:binding binding}))]))
