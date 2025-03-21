extends Node

var money = "0"
var realmoney = 1890

func convert_money():
	match realmoney:
		0: money = "0";
		_ when realmoney < 1_000:
			money = str(realmoney);
		_ when realmoney < 1_000_000:
			money = "%.2fK" % (realmoney / 1_000.0)
		_ when realmoney < 1_000_000_000:
			money = "%.2fM" % (realmoney / 1_000_000.0)
		_ when realmoney < 1_000_000_000_000:
			money = "%.2fB" % (realmoney / 1_000_000_000.0)
		_ when realmoney < 1_000_000_000_000_000:
			money = "%.2fT" % (realmoney / 1_000_000_000_000.0)
		_ when realmoney < 1_000_000_000_000_000_000:
			money = "%.2fQa" % (realmoney / 1_000_000_000_000_000.0) # Quadrillion
