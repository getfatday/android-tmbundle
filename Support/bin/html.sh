put_err() {
    echo "<span class=\"error\">Error: $1</span>"
}

put_style() {
    cat <<'HTML'
        <style type="text/css">
            body{
             margin:0;
             padding: 60px 10px 10px 10px;
             background:#ddd;
            }
            h1#header{
             position:absolute;
             top:0;
             left:0;
             width:100%;
             height:30px;
             background:#AACA46;
             color:#fff;
             padding:10px;
             margin: 0;
             border-bottom:solid 3px #aaa;
            }
            @media screen{
             body>h1#header{
              position: fixed;
             }
            }
            * html body{
             overflow:hidden;
            } 
            * html div#content{
             height:100%;
             overflow:auto;
            }
            a {
                color:#391;
            }
            .error {
                color:#f00;
            }
            span.error {
                display:block;
                font-weight:bold;
            }
            .section {
                padding-bottom: 15px;
                border-top: solid 1px #ccc;
            }
            
            div#content > div.section:first-child {
                border: 0;
            }
        </style>
HTML
}

put_block() {
    echo -n "$1"
    cat
    echo "$2"
}

put_line() {
    echo "<p class='line'>$1</p>"
}

put_header() {
    put_block "<div class='section'><h3>$1</h3>" "</div>"
}

put_footer() {
	echo "</div></body></html>"
}

put_window() {
    echo "<html><head><title>$1</title>"
    put_style
    echo "</head><body><h1 id='header'>$1</h1>"
    put_block "<div id='content'>" "</div>"
    echo "</body></html>"
}

put_javac() {
	echo -n '<pre style="word-wrap: break-word;">'
    perl -pe '$| = 1; s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; s/\/([^:]*):([^:]*):(.*)/<a class="error" href="txmt:\/\/open?url=file:\/\/\/$1\&line=$2">\/$1:$2<\/a>:$3/; s/$\\n/<br>/'
	echo '</pre>'
}