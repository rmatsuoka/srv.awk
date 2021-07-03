#!/usr/bin/awk -f

# srv.awk -- Toy http server which returns a html displaying Path of URL.
#
# example:
# $ mkfifo p.fifo
# $ srv.awk -v fifo=p.fifo
# access at localhost:8000/hello_world via a web browser.

BEGIN{
	# use in global
	Progname="srv.awk"
	Usage=Progname " -v fifo=FIFO"
	Stderr="cat >&2"

	if("" == fifo || system("test -p " fifo))
		error("set a fifo")

	recv=fifo
	host="localhost"
	port="8000"

	# - send a message
	#   print MESSAGE | conn
	# - receive a data
	#   getline < recv
	conn=sprintf("nc -l %s %s > %s", host, port, recv)

	for(;;){
		# reset
		i=1
		# "delete ARR" is not standardized in POSIX awk.
		delete header

		# run netcat
		printf "" | conn

		for(;;){
			if(getline data < recv)
				if("\r" == data)
					break
				else{
					sub(/\r/,"",data)
					header[i++]=data
				}
			else
				break
		}
		handle(conn, header)
		close(recv)
		close(conn)
		# debugMsg("close(conn) done")
	}
}

function error(msg){
	print Progname ": " msg | Stderr
	print "usage: " Usage | Stderr
	exit(1)
}

# use only in debugging
function debugMsg(msg){
	print "# debug: " msg | Stderr
	# "fflush()" is not standardized in POSIX awk.
	fflush(Stderr)
}

# send a message to "to"
function send(to, msg){
	print msg | to
}

function handle(to, header,     urlPath, arr){
	split(header[1], arr)
	urlPath=arr[2]
	sub(/\//, "", urlPath)

	send(to, "HTTP/1.1 200 OK\r")
	send(to, "Content-Type: text/html; charset=UTF-8\r")
	send(to, "Connection: close\r")
	send(to, "\r")
	send(to, "<html>\r")
	send(to, "<head><title>" urlPath "</title></head>\r")
	send(to, "<body><h1>" urlPath "</h1></body>\r")
	send(to, "</html>\r")
}
