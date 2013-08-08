class StorageHelper

    constructor: (callback) ->
        if !window.indexedDB
            window.alert "Your browser doesn't support a stable version of IndexedDB. Such and such feature will not be available."
            return
        else
            request = window.indexedDB.open database_name, 2
            request.onerror = (e) ->
                callback e
            
            request.onsuccess = (e) =>
                @db = request.result
                callback null

            request.onupgradeneeded = (event) ->
                db = event.target.result
                objectStore = db.createObjectStore file_store_name, { "autoIncrement": true }

    write_array: (array, mime_type, callback) ->
        pk = null
        transaction = @db.transaction [file_store_name], "readwrite"
        
        transaction.onerror = (e) ->
            callback err if err?

        transaction.oncomplete = (event) ->
            callback null, pk if callback?

        objectStore = transaction.objectStore file_store_name

        request = objectStore.add { array: array, mime_type: mime_type }
        request.onsuccess = (event) ->
            pk = event.target.result 

    read_array: (key, callback) ->
        transaction = @db.transaction [file_store_name]
        
        transaction.onerror = (e) ->
            callback err if err?

        objectStore = transaction.objectStore file_store_name

        request = objectStore.get key
        request.onsuccess = (event) ->
            callback null, request.result if callback?

log = (event) ->
    console.log "Error: #{e.target.errorCode}"

test = (url) ->
    url = url || 'http://www.html5rocks.com/index.html'
    xhr = new XMLHttpRequest()
    xhr.open 'GET', url, true
    xhr.responseType = 'arraybuffer'

    xhr.onreadystatechange = (e) ->
        if (xhr.readyState == 4)
            input_array = new Uint8Array(xhr.response)
            sec = new StorageHelper (err) ->
                return err if err?
                sec.write_array input_array, xhr.getResponseHeader('Content-Type'), (err, key) ->
                    return err if err?
                    sec.read_array key, (err, result) ->
                        return err if err?
                        console.log "read_array len is #{result.array.byteLength}"
                        blob = new Blob([result.array], {type: result.mime_type})
                        window.open window.URL.createObjectURL(blob)
    xhr.send()