(import joy :prefix "")
(import ../helpers :prefix "")
(import moondown)


(defn set-html [{:url url :ref ref}]
  (string/format `get('%s', 'text/html').then(html => $refs.%s.innerHTML = html)` url ref))


(defn list [examples]
  [:vstack {:spacing "xl"}
   (foreach [ex examples]
     [:vstack {:spacing "xs"}
      [:pre
       [:code {:class "clojure"}
        (raw (moondown/render (ex :body)))]]
      [:hstack {:spacing "m" :align-x "right"}
       [:a {:href (string "/" (ex :binding))}
        (ex :binding)]
       [:a {:href (string "https://github.com/" (ex :login))}
        (ex :login)]]])])


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
    (if (get session :login)
      [:span
       [:a {:href "" :x-show "newExample" :@click.prevent "newExample = false"}
        "Cancel"]
       [:a {:x-show "!newExample"
            :href (url-for :examples/new {:binding-id (binding :id)})
            :@mouseenter.once (set-html {:url (url-for :examples/form {:binding-id (binding :id)})
                                         :ref "form"})
            :@click.prevent "newExample = true"}
        "Add an example"]]
      [:span
       [:a {:href (string/format "https://github.com/login/oauth/authorize?client_id=%s"
                                 (env :github-client-id))}
        "Sign in to add an examplee"]])]

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
        [:a {:href (string "https://github.com/" (ex :login))}
         (ex :login)]
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
  (def {:params params :example example} request)

  (def html (form-for [request (if example :examples/patch :examples/create) {:id (get example :id) :binding-id (params :binding-id)}]
              [:vstack {:spacing "m"}
               [:vstack
                [:label {:for "body"} (if example
                                        "Edit example"
                                        "New example")]
                [:textarea {:rows "10" :name "body" :autofocus ""}
                 (get example :body)]
                [:div {:style "color: red"}
                 (get-in request [:errors :body])]]

               [:vstack
                [:button {:type "submit"}
                 "Save example"]]]))

  (if (xhr? request)
    (text/html html)
    html))


(defn new [request]
  (when-let [account (current-account request)
             binding (db/fetch [:binding (get-in request [:params :binding-id])])]

    (let [package (db/find :package (or (binding :package-id) 0))
          binding (merge binding {:package package})
          request (merge request {:binding binding})]

      [:vstack
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
