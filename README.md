# VAPE
The VAPE stack is Vuejs, Apollo, Postgraphql, and Expressjs. Presentation is handled in single-file vuejs components/views. Business logic is handled at the db level by postgresql. Postgraphql makes connecting the two simple.

## Postgraphql
Don't forget to create db users

## Server crash 20180614
Server crashed for unknown reason - prob restart
had to:
```
pgrep node | xargs kill -9
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
forever start -c 'npm start' ./ # from ~/vape
```
