(import joy :prefix "")
(import ../helpers :prefix "")

(defn playground [request code]
  #(def account (current-account request))
  (def html
  [:vstack {:spacing "l"}
    [:script {:src "/ace/ace.js"}]
    [:hstack {:spacing "s"}
        [:button {:id "run" :title="ctrl-enter"} "Run"]
        [:button {:id "format"} "Format"]
        [:spacer]]
      [:div {:id "code" :class "hljs" :style "height:60vh;"} (raw code)]
      [:pre {:id "output" :style "overflow:auto;"}]
      [:div {:id "hiddencode" :style "display:none;"}]
      [:div {:id "sporkformat" :style "display:none;"}
       (string (slurp "public/playground/fmt.janet"))]
    [:script {:type "text/javascript" :src "/playground/playground.js" :async "false"}]
    [:script {:type "text/javascript" :src "/playground/janet.js" :async "false"}]
    [:script {:type "text/javascript" :src "/playground/jdocs_playground.js" :async "false"}] 
    ])
  (if (xhr? request)
    (text/html html)
    html)
  )

(defn home [request]
  (def code ```
            # Enter Janet code here and click "Run" or Ctrl-Enter
            (print "Hello, World!")
            ```)
  (playground request code))

(defn example [request]
  (if-let [id (get-in request [:params :id])
           example (db/fetch [:example (scan-number id)])
           code (get example :body) ]
    (playground request (string code "\n"))
    (home request)))

