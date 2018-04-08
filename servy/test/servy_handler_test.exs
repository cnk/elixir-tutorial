defmodule ServyHandlerTest do
  use ExUnit.Case
  doctest Servy.Handler

  test "request for /wildthings returns 'Lions, Tigers, Bears'" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Lions, Tigers, Bears
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "single alias: request for /wildlife returns 'Lions, Tigers, Bears'" do
    request = """
    GET /wildlife HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Lions, Tigers, Bears
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for /bears returns 'Teddy, Smokey, Paddington'" do
    request = """
    GET /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 25

    Teddy, Smokey, Paddington
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for specific bear returns that bear" do
    request = """
    GET /bears/1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 6

    Bear 1
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for bears/new returns a form for creating a new bear" do
    request = """
    GET /bears/new HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 232

    <form action="/bears" method="POST">
      <p>
        Name:<br/>
        <input type="text" name="name">
      </p>
      <p>
        Type:<br/>
        <input type="text" name="type">
      </p>
      <p>
        <input type="submit" value="Create Bear">
      </p>
    </form>

    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "rewrite ids: request for specific bear with query args returns that bear" do
    request = """
    GET /bears?id=1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 6

    Bear 1
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for undefined route returns status 404" do
    request = """
    GET /missing_path HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 404 Not Found
    Content-Type: text/html
    Content-Length: 15

    File not found.
    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request to delete bears returns status 204" do
    request = """
    DELETE /bears/2 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 204 No Content
    Content-Type: text/html
    Content-Length: 0


    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for static file returns file cotents" do
    request = """
    GET /about HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 42

    <h1>About Us</h1>

    <p>
    All about us.
    </p>

    """

    assert Servy.Handler.handle(request) == expected_response
  end

  test "request for another static file returns it's cotents" do
    request = """
    GET /contact HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 53

    <h1>Contact Us</h1>

    <p>
      Contact us by email.
    </p>

    """

    assert Servy.Handler.handle(request) == expected_response
  end
end
