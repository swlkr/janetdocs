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

(defn find-binding-id [name]
  (let [binding (joy/db/find-by :binding :where {:name name})]
   (if binding (binding :id) nil)))
   

(loop [d :in alldocs]
  (let [b (find-binding-id (d :name))]
    (if b
      (joy/db/update :binding b {:docstring (d :docstring) # fix shadowed bindings and ? url problem
                                 :name (d :name)})
      (joy/db/insert :binding {:name (d :name)
                               :docstring (d :docstring)}))))

# Links that appear under "See also"
(def links
  [
   ["%" "mod"]
   ["each" "eachk" "eachp"]
   ["file/close" "file/open"]
   ["file/open" "file/close"]
   ["file/read" "slurp"]
   ["mod" "%"]
   ["print" "printf" "pp"]
   ["prompt" "return"]
   ["return" "prompt"]])

(each lnk links
  (let [src (first lnk)
        targets (drop 1 lnk)]
    (each t targets
      (let [source (find-binding-id src)
            target (find-binding-id t)
            exists (joy/db/find-by :link :where {:source (string source) :target (string target)})]
        (if (nil? exists)
            (joy/db/insert :link {:source source :target target}))))))

(joy/db/disconnect)
