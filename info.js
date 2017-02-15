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
    net.setHost('https://giftcards.ebay.com');

    this.checkAuth = function(callback) {
        net.get('/gift/?itemId=252347907159&bulkShopCart&bin=https%3A%2F%2Fpay.ebay.com%2Fxo%3Faction%3Dcreate%26rypsvc%3Dtrue%26pagename%3Dryp%26TransactionId%3D-1%26item%3D252347907159&cart=http%3A%2F%2Fcart.payments.ebay.com%2Fsc%2Fadd%3Fsrt%3D010001000000505407c62b67fe0d23eaf7b2a6614818ea6278e7bd24b62ca390861fd7a37b483f7ed797a96ad734ab2512862b3df7e54770e2077d5f670ff7095923497b956a801c9ee2e0f2f74cf2f2b3c07e04774b2b%26ssPageName%3DCART%3AATC&item=iid:252347907159,qty:1,vid:551193564290&showGiftYes', function(response) {
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
