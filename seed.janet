(def allbindings (all-bindings))

(import dotenv)
(dotenv/load)

(import joy)

(def alldocs @[])

(loop [b :in allbindings]
  (when (not= "allbindings" (string b))
    (do
      (def buf @"")
      (with-dyns [:out buf]
        (doc* b)
        (array/push alldocs {:name (string b) :docstring (string buf)})))))

(joy/db/connect)

(loop [d :in alldocs]
  (def b (joy/db/find-by :binding :where {:name (d :name)}))
  (if b
    (joy/db/update :binding b {:docstring (d :docstring) # fix shadowed bindings and ? url problem
                               :name (d :name)})
    (joy/db/insert :binding {:name (d :name)
                             :docstring (d :docstring)})))

(joy/db/disconnect)
