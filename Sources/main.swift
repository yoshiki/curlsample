import CCurl

// a class to store received data
class Received {
    var data = String()
}

class Send {
    let data = "{ \"foo\": [ \"bar\", \"baz\" ] }"
}

let handle = curl_easy_init()

// set url
let url = "http://www.example.com"
url.withCString {
    curlHelperSetOptString(handle, CURLOPT_URL, UnsafeMutablePointer($0))
}

curlHelperSetOptInt(handle, CURLOPT_HTTP_TRANSFER_DECODING, 0)

// set verbose
curlHelperSetOptBool(handle, CURLOPT_VERBOSE, CURL_TRUE)

// set timeout
let timeout = 3
curlHelperSetOptInt(handle, CURLOPT_TIMEOUT, timeout)

curlHelperSetOptBool(handle, CURLOPT_POST, CURL_TRUE)

// set header
var headersList: UnsafeMutablePointer<curl_slist> = nil
var headers: [(String, String)] = [
    // ("Content-Type", "text/plain"),
    // ("Accept", "application/json"),
    // ("Charset", "utf8"),
]
for (key, value) in headers {
    let header = "\(key): \(value)"
    header.withCString {
        headersList = curl_slist_append(headersList, UnsafeMutablePointer($0))
    }
}
if headersList != nil {
    curlHelperSetOptHeaders(handle, headersList)
}

// set post fields
var send = Send()
send.data.withCString {
    let data = UnsafeMutablePointer<Int8>($0)
    curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, Int(strlen(data)))
}

curlHelperSetOptReadFunc(handle, &send) { (buf: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
    let p = UnsafePointer<Send?>(privateData)
    let len = size * nMemb
    if let data = p.memory?.data {
        memcpy(buf, data, len)
    }
    return len
}


// set write func
var received = Received()
curlHelperSetOptWriteFunc(handle, &received) { (ptr: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
    let p = UnsafePointer<Received?>(privateData)
    if let line = String.fromCString(ptr) {
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

if headersList != nil {
    curl_slist_free_all(headersList)
}
