(import joy :prefix "")
(import ../helpers :prefix "")
(import ./examples)
(import uri)


(defn show [request]
  (when-let [[name] (request :wildcard)
             name (uri/unescape name)
             name (string/replace "_q" "?" name)
             binding (first (db/query (slurp "db/sql/search.sql") [name]))]

    [:vstack {:spacing "m"}
     (binding-header binding)
     (examples/index (merge request {:binding binding}))]))
