# srv.awk
Toy http server written in awk and netcat
This returns a html displaying a request URL path.

## usage

```shell
$ mkfifo p.fifo
$ ./srv.awk -v fifo=p.fifo
````

## Note
* `nc` is not standardized. You may have to modify this program.
* If your `awk` is `mawk`, then you should specify `-W interactive`.
