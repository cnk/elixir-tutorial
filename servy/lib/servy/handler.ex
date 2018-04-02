defmodule Servy.Handler do
  @moduledoc """
  Basic HTTP handler. Accepts a request, parses it, routes, and
  returns a formatted response.
  """

  def handle(request) do
    request
    |> parse
    |> rewrite
    |> route
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{ method: method, path: path, resp_body: "", status: nil }
  end

  def rewrite( %{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite( %{path: "/bears?id=" <> id } = conv) do
    %{ conv | path: "/bears/#{id}" }
  end

  def rewrite(conv), do: conv

  def route( %{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Lions, Tigers, Bears" }
  end

  def route( %{method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route( %{method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route( %{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{ conv | status: 204 }
  end

  def route( %{path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here." }
  end

  def emojify(%{status: 200} = conv) do
    body = "\u{1F60E}" <> " " <> conv.resp_body <> "\u{1F60E}" <> " "
    %{ conv | resp_body: body }
  end

  def emojify(conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      204 => "No Content",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
