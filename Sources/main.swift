import CCurl

let handle = curl_easy_init()

let url = "https://www.example.com"
url.withCString {
    curlHelperSetOptString(handle, CURLOPT_URL, UnsafeMutablePointer($0))
}
curlHelperSetOptBool(handle, CURLOPT_VERBOSE, CURL_TRUE)

let ret = curl_easy_perform(handle)
let error = curl_easy_strerror(ret)
print("error = \(error)")
print("ret = \(ret)")

curl_easy_cleanup(handle)
