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

	host="localhost"
	port="8000"

	# for netcat of Ubuntu (OpenBSD variant)
	recv=sprintf("nc -lNC %s %s > %s", host, port, fifo)
	# for macOS
	# recv=sprintf("nc -lc %s %s > %s", host, port, fifo)

	for(;;){
		# reset
		i=1
		delete header
		# run recv
		printf "" | recv

		#debugMsg("fflush(recv) done")
		for(;;){
			if(getline data < fifo)
				if("\r" == data)
					break
				else{
					sub(/\r/,"",data)
					header[i++]=data
				}
			else
				break
		}
		handle(header, recv)
		close(fifo)
		close(recv)
		#debugMsg("close(recv) done")
	}
}

function error(msg){
	print Progname ": " msg | Stderr
	print "usage: " Usage | Stderr
	exit(1)
}
function debugMsg(msg){
	print "# debug: " msg | Stderr
	fflush(Stderr)
}

function handle(header, to,    urlPath, arr){
	split(header[1], arr)
	urlPath=arr[2]
	sub(/\//, "", urlPath)

	print "HTTP/1.1 200 OK" | to
	print "" | to
	print "<html>" | to
	print "<head><title>" urlPath "</title></head>" | to
	print "<body><h1>" urlPath "</h1></body>" | to
	print "</html>" | to
}
