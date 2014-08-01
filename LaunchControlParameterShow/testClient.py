import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("127.0.0.1", 12000))

bankJSON = '{\
	"name": "Side Chain",\
	"params": [\
		{\
			"name": "EQ On"\
		},\
		{\
			"name": "EQ Mode"\
		},\
		{\
			"name": "EQ Freq"\
		},\
		{\
			"name": "EQ Q"\
		},\
		{\
			"name": "EQ Gain"\
		},\
		{\
			"name": "Ext. In On"\
		},\
		{\
			"name": "Ext. In Mix"\
		},\
		{\
			"name": "Ext. In Gain"\
		}\
	]\
}'

s.send(bankJSON)

s.close()