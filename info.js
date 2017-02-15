function fNet() {
    this.setHost = function(host){
        this.host = host;
    };
    this.get = function(a, b) {
        var myRequst = new XMLHttpRequest();
        myRequst.open('GET', this.host + a, (b === false) ? false : true);
        myRequst.send(null);

        if (b) {
            myRequst.onreadystatechange = function() {
                if ((myRequst.readyState == 4) && (myRequst.status == 200)) {
                    b(myRequst.responseText);
                }
            }
        } else {
            if (myRequst.status == 200) {
                return myRequst.responseText;
            }
        }
        return false;
    };

    this.post = function(url, postData, callback){
        var myRequst = new XMLHttpRequest();
        myRequst.open('POST', this.host + url, (callback === false) ? false : true);
        myRequst.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

        data = Object.keys(postData).map(function(k) {
            return encodeURIComponent(k) + '=' + encodeURIComponent(postData[k])
        }).join('&');

        myRequst.send(data);

        if (callback) {
            myRequst.onreadystatechange = function() {
                if ((myRequst.readyState == 4) && (myRequst.status == 200)) {
                    callback(myRequst.responseText);
                }
            }
        } else {
            if (myRequst.status == 200) {
                return myRequst.responseText;
            }
        }
        return false;
    }
}



var fWebOk = function() {
    var net = new fNet;
    var gwtHash;
    var token;
    var postpostForm;
    net.setHost('http://m.ebay.com');

    this.checkAuth = function(callback) {
        net.get('/', function(response) {
            if (response.indexOf('iTunes Codes') == -1) {
                                console.log(1);

            } else {
                                console.log(0);
                
            }
        });
    };

    this.like = function(discussion_id, callback) {
        net.get('/dk?cmd=MediaTopicLayerBody', {
            'gwt.requested': gwtHash,
            'st.mt.id': discussion_id,
            'st.mt.ot': 'USER',
            'st.mt.wc': 'off',
            'st.mt.hn': 'off'
        }, function(r) {
            if (r) {
                console.log(1);
            }
        });
    };

};

var fok = new fWebOk;
fok.checkAuth();
