from ..rpc import RPCServer

rpc_server = RPCServer()


@rpc_server.register
def tokenize(text):
    return text.split()


if __name__ == "__main__":
    rpc_server.serve(host="0.0.0.0", port=2345)
