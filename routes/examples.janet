(import joy :prefix "")
(import ../helpers :prefix "")
(import uri)


(defn set-html [{:method method :input input :url url :ref ref}]
  (def method (or method "get"))
  (def f (if (= "post" method)
           (string/format "post('%s', %s, 'text/html')" url input)
           (string/format "get('%s', 'text/html')" url)))
  (string/format `%s.then(html => $refs.%s.innerHTML = html);` f ref))


(defn list [examples]
  [:vstack {:spacing "xl"}
   (foreach [ex examples]
     [:vstack {:spacing "xs"}
      [:pre
       [:code {:class "clojure"}
        (ex :body)]]
      [:hstack {:spacing "m" :align-x "right"}
       [:a {:href (string "/" (uri/escape (get-in ex [:binding :name])))}
        (get-in ex [:binding :name])]
       [:a {:href (string "https://github.com/" (get-in ex [:account :login]))}
        (get-in ex [:account :login])]]])])

(defn format-see-also-link [link]
  (let [name (link :name)]
    [:a {
         :href (string "/" name)
         :class "see-also"}
     name])) 

(defn see-also [binding-id]
  (let [links (db/query `select 
                          binding.name
                         from link
                         join 
                           binding on link.target = binding.id
                         where 
                           link.source = ?
                         order 
                           by binding.name`
                        [binding-id])]
    (if (empty? links) 
     []
     [:hstack [:strong "See also:"] (map format-see-also-link links)])))

(defn index [request]
  (def {:binding binding :session session} request)
  (def examples (db/query `select example.*, account.login as login
                           from example
                           join account on account.id = example.account_id
                           where example.binding_id = ?
                           order by example.created_at desc`
                          [(binding :id)]))

  [:vstack {:spacing "xl" :x-data "{ editing: false, add: true, adding: false, examples: {} }" :@cancel-new "editing = false" :@cancel-edit "add = true" :@edit-example "add = false"}
   (see-also (binding :id))
   [:hstack
    [:strong (string (length examples) (singularize " examples" (length examples)))]
    [:spacer]
    (if (get session :login)
      [:span
       [:a {:x-show "add && !editing"
            :id "add-example"
            :style "cursor: pointer"
            :@mouseenter.once (set-html {:url (url-for :examples/form {:binding-id (binding :id)})
                                         :ref "form"})
            :@click.prevent "editing = true; $dispatch('new-example')"}
        "Add an example"]]
      [:span
       [:a {:href (string/format "https://github.com/login/oauth/authorize?client_id=%s"
                                 (env :github-client-id))}
        "Sign in to add an example"]])]

   [:vstack {:spacing "m"}
    [:div {:x-show "editing" :x-ref "form"}
     "Loading..."]
    [:vstack {:x-show "!editing" :spacing "xl"}
     (foreach [ex examples]
       [:vstack {:spacing "xs" :x-data "{ editing: false }" :@cancel-edit "editing = false"}
        [:div {:x-show "editing" :x-ref "editor"}]
        [:pre {:x-show "!editing"}
         [:code {:class "clojure"}
          (ex :body)]]
        [:hstack
         [:a {:href (string "https://github.com/" (ex :login)) :x-show "!editing"}
          (ex :login)]
         [:spacer]
         (when (= (get session :login)
                  (ex :login))
           [:hstack {:spacing "l"}
            [:a {:x-show "!editing"
                 :href (url-for :examples/edit ex)
                 :@mouseenter.once (set-html {:url (url-for :examples/edit ex)
                                              :ref "editor"})
                 :@click.prevent "editing = true; $dispatch('edit-example')"}
             "Edit"]

            [:span {:x-show "!editing"}
             (delete-button request (url-for :examples/destroy ex))]])]])]]])


(defn form [request]
  (def {:params params :example example} request)

  (def html (form-for [request (if example :examples/patch :examples/create) {:id (get example :id) :binding-id (params :binding-id)}]
              [:vstack {:spacing "m" :x-data "{ preview: false, body: '' }" :x-init "() => { body = $refs.initialBody.value }"}
               [:textarea {:style "display: none" :x-ref "initialBody"}
                 (get example :body)]
               [:vstack {:spacing "xs"}
                [:hstack {:spacing "m"}
                 [:a {:href "#" :x-bind:style "!preview ? 'text-decoration: underline' : ''"
                      :@click.prevent "preview = false"}
                  "Edit"]
                 [:a {:href "#"
                      :x-bind:style "preview ? 'text-decoration: underline' : ''"
                      :@click.prevent "preview = true; setTimeout(function() { highlight() }, 0)"}
                  "Preview"]
                 [:spacer]
                 [:a {:href "" :@click.prevent (string
                                                 "preview = false; "
                                                 (if (get example :id) "$dispatch('cancel-edit')" "$dispatch('cancel-new')"))}
                  "Cancel"]]
                [:pre
                 [:code {:x-show "preview" :x-text "body" :class "clojure"}]]
                [:textarea {:x-show "!preview" :x-model "body" :rows "10" :name "body" :autofocus ""}
                 (get example :body)]
                [:hstack
                 [:div {:style "color: red"}
                  (get-in request [:errors :body])]]
                [:vstack
                 [:button {:type "submit"}
                  "Save example"]]]]))

  (if (xhr? request)
    (text/html html)
    html))


(defn new [request]
  (when-let [account (current-account request)
             binding (db/fetch [:binding (get-in request [:params :binding-id])])]

    (let [package (db/find :package (or (binding :package-id) 0))
          binding (merge binding {:package package})
          request (merge request {:binding binding})]

      [:vstack {:spacing "xl"}
       (binding-header binding)
       (let [result (form request)]
         (if (dictionary? result)
           (raw (get result :body))
           result))])))


(defn create [request]
  (when-let [login (get-in request [:session :login])
             account (db/find-by :account :where {:login login})]

    (def {:body body :params params} request)

    (if (blank? (body :body))
      (new (merge request {:errors {:body "Body can't be blank"}}))

      (do
        (db/insert :example {:account-id (account :id)
                             :binding-id (params :binding-id)
                             :body (body :body)})


        (def binding (db/find :binding (params :binding-id)))

        (redirect (binding-show-url binding))))))


(defn edit [request]
  (when-let [account (current-account request)
             example (db/fetch [:account account :example (scan-number (get-in request [:params :id] 0))])]

    (form (merge request {:example example}))))


(defn patch [req]
  (when-let [account (current-account req)
             example (db/fetch [:account account :example (get-in req [:params :id] 0)])
             body (req :body)
             binding (db/find :binding (example :binding-id))]

    (if (blank? body)
      (edit (merge req {:error {:body "Body can't be blank"}}))
      (do
        (db/update :example example {:body (body :body)})
        (redirect (binding-show-url binding))))))


(defn destroy [request]
  (when-let [account (current-account request)
             example (db/fetch [:account account :example (get-in request [:params :id])])]

    (db/delete :example (example :id))

    (def binding (db/find :binding (example :binding-id)))

    (redirect (binding-show-url binding))))


(defn random [request]
  (let [binding (first (db/query (slurp "db/sql/random.sql")))]

    (def html
      [:vstack {:spacing "m"}
       (binding-header binding)
       (index (merge request {:binding binding}))])

    (if (xhr? request)
      (text/html html)
      html)))
