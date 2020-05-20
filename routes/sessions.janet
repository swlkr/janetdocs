(use joy)


(defn destroy [request]
  (-> (redirect-to :home/index)
      (put :session @{})))
