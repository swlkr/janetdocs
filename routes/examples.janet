(import joy :prefix "")
(import ../helpers :prefix "")
(import moondown)


(defn set-html [{:url url :ref ref}]
  (string/format `get('%s', 'text/html').then(html => $refs.%s.innerHTML = html)` url ref))


(defn index [request]
  (def {:binding binding :session session} request)
  (def examples (db/query `select example.*, account.login as login
                           from example
                           join account on account.id = example.account_id
                           where example.binding_id = ?
                           order by example.created_at desc`
                          [(binding :id)]))

  [:vstack {:spacing "m" :x-data "{ newExample: false }"}
   [:hstack
    [:strong (string (length examples) (pluralize " examples" (length examples)))]
    [:spacer]
    (when (get session :login)
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
      [:vstack {:spacing "xs" :x-data "{ editing: false }"}
       [:div {:x-show "editing" :x-ref "editing"}]
       [:pre {:x-show "!editing"}
        [:code {:class "clojure"}
         (raw (moondown/render (ex :body)))]]
       [:hstack
        [:strong (ex :login)]
        [:spacer]
        (when (= (get session :login)
                 (ex :login))
          [:hstack {:spacing "l"}
           [:a {:x-show "!editing"
                :href (url-for :examples/edit ex)
                :@mouseenter.once (set-html {:url (url-for :examples/edit ex)
                                             :ref "editing"})
                :@click.prevent "editing = true"}
            "Edit"]
           [:a {:x-show "editing" :@click.prevent "editing = false" :href "#"}
            "Cancel"]

           (delete-button request (url-for :examples/destroy ex))])]])]])


(defn form [request]
  (def params (request :params))

  (text/html
    (form-with request (action-for :examples/create {:binding-id (params :binding-id)})
      [:vstack {:spacing "m"}
       [:vstack
        [:label {:for "body"} "New example"]
        [:textarea {:rows "10" :name "body" :autofocus ""}]]

       [:vstack
        [:button {:type "submit"}
         "Add example"]]])))


(defn new [request]
  (let [binding (db/fetch [:binding (get-in request [:params :binding-id])])
        package (db/find :package (binding :id))
        binding (merge binding {:package package})
        request (merge request {:binding binding})]

    [:vstack
     (binding-header binding)
     (raw (get (form request) :body))]))


(defn create [request]
  (when-let [login (get-in request [:session :login])
             account (db/find-by :account :where {:login login})]

    (def {:body body :params params} request)

    (db/insert :example {:account-id (account :id)
                         :binding-id (params :binding-id)
                         :body (body :body)})


    (def binding (db/find :binding (params :binding-id)))

    (redirect (binding-show-url binding))))
