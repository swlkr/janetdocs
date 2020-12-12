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
   ["*" "product"]
   ["+" "sum"]
   ["+=" "inc"]
   ["accumulate" "reduce"]
   ["all" "some" "any?"]
   ["and" "band"]
   ["any?" "some" "all"]
   ["case" "match" "cond"]
   ["chr" "string/bytes" "string/from-bytes"]
   ["defmacro" "macex"]
   ["defn" "defn-"]
   ["each" "eachk" "eachp"]
   ["false?" "true?" "truthy?"]
   ["file/close" "file/open"]
   ["file/open" "file/close" "with"]
   ["file/read" "slurp"]
   ["file/write" "spit"]
   ["filter" "keep"]
   ["find" "find-index"]
   ["find-index" "find"]
   ["first" "take" "last"]
   ["inc" "dec" "+="]
   ["keep" "filter"]
   ["keys" "values" "kvs" "pairs"]
   ["kvs" "pairs" "keys" "values"]
   ["match" "case"]
   ["mod" "%"]
   ["not" "complement" "bnot"]
   ["or" "bor"]
   ["pairs" "kvs" "keys" "values"]
   ["pp" "print" "printf"]
   ["print" "printf" "pp"]
   ["printf" "string/format"]
   ["prompt" "return"]
   ["put" "put-in"]
   ["put-in" "put"]
   ["reduce" "reduce2" "accumulate"]
   ["reduce2" "reduce"]
   ["return" "prompt"]
   ["slurp" "spit"]
   ["some" "all" "any?"]
   ["sort" "sort-by" "sorted"]
   ["sorted" "sorted-by" "sort"]
   ["string/bytes" "string/from-bytes" "chr"]
   ["string/format" "printf"]
   ["take" "first"]
   ["true?" "false?" "truthy?"]
   ["truthy?" "true?"]
   ["values" "keys" "kvs" "pairs"]])
   

(each lnk links
  (let [src (first lnk)
        targets (drop 1 lnk)]
    (each t targets
      (let [source (find-binding-id src)
            target (find-binding-id t)
            exists (joy/db/find-by :link :where {:source (string source) :target (string target)})]
        (if (not (and source target))
          (errorf "Invalid link from '%s' (id=%s) to '%s'(id=%s)" src (string source) t (string target))
          (if (nil? exists)
              (joy/db/insert :link {:source source :target target})))))))

(joy/db/disconnect)
