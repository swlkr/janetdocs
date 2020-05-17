(import joy :prefix "")
(import ../helpers :prefix "")


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
