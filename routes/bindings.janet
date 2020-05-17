(import joy :prefix "")
(import ../helpers :prefix "")
(import moondown)


(defn set-html [{:url url :ref ref}]
  (string/format `fetch('%s')
   .then(response => response.text())
   .then(html => { $refs.%s.innerHTML = html})`
   url ref))


(defn show [request]
  (when-let [name (request :wildcard)
             binding (first (db/query (slurp "db/sql/search.sql") [name]))
             examples (db/query `select example.*, account.login as login
                                 from example
                                 join account on account.id = example.account_id
                                 where example.binding_id = ?
                                 order by example.created_at desc`
                                [(binding :id)])]

    [:vstack {:spacing "m"}
     (binding-header binding)

     [:vstack {:spacing "m" :x-data "{ newExample: false }"}
      [:hstack
       [:strong (string (length examples) (pluralize " examples" (length examples)))]
       [:spacer]
       (when (get-in request [:session :login])
         [:span
          [:a {:href "" :x-show "newExample" :@click.prevent "newExample = false"}
           "Cancel"]
          [:a {:x-show "!newExample"
               :href (url-for :examples/new {:binding-id (binding :id)})
               :@mouseenter.once (set-html {:url (url-for :examples/form {:binding-id (binding :id)})
                                            :ref "form"})
               :@click.prevent "newExample = true"}
           "Add an example"]])]

      [:vstack {:spacing "m"}
       [:div {:x-show "newExample" :x-ref "form"}
        "Loading..."]
       (foreach [ex examples]
         [:vstack
          [:pre
           [:code
             (raw (moondown/render (ex :body)))]]
          [:strong (ex :login)]])]]]))
