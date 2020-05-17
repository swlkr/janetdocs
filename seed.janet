(def allbindings (all-bindings))

(import dotenv)
(dotenv/load)
(use joy)

(def alldocs @[])

(loop [b :in allbindings]
  (def buf @"")
  (with-dyns [:out buf]
    (doc* b)
    (array/push alldocs {:name (string b) :docstring (string buf)})))

(db/connect)

# (var package (db/find-by :package :where {:name "core"}))
# (unless package
#  (set package (db/insert :package {:name "core" :url "https://github.com/janet-lang/janet/blob/master/src/boot/boot.janet"})))

(loop [d :in alldocs]
  (def b (db/find-by :binding :where {:name (d :name)})) # :package-id (package :id)}))
  (unless b
    (db/insert :binding {:name (d :name)
                         :docstring (d :docstring)})))
                         #:package-id (package :id)})))

(db/disconnect)
