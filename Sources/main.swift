import CCurl

let handle = curl_easy_init()

// set url
let url = "https://www.example.com"
url.withCString {
    curlHelperSetOptString(handle, CURLOPT_URL, UnsafeMutablePointer($0))
}

// set verbose
curlHelperSetOptBool(handle, CURLOPT_VERBOSE, CURL_TRUE)

// set timeout
let timeout = 3
curlHelperSetOptInt(handle, CURLOPT_TIMEOUT, timeout)

// a class to store received data
class Received {
    var data = String()
}

// set write func
var received = Received()
curlHelperSetOptWriteFunc(handle, &received) { (buf: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
    let p = UnsafePointer<Received?>(privateData)
    if let line = String.fromCString(buf) {
        p.memory?.data.appendContentsOf(line)
    }
    return size * nMemb
}

// perform
let ret = curl_easy_perform(handle)

// result handling
if ret == CURLE_OK {
    print(received.data)
} else {
    let error = curl_easy_strerror(ret)
    if let errStr = String.fromCString(error) {
        print("error = \(errStr)")
    }
    print("ret = \(ret)")
}

// cleanup
curl_easy_cleanup(handle)
