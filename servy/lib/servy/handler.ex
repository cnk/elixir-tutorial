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
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def rewrite(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite(%{path: "/bears/new"} = conv) do
    %{conv | path: "/form"}
  end

  def rewrite(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_id_captures(conv, captures)
  end

  def rewrite(conv), do: conv

  def rewrite_id_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_id_captures(conv, nil), do: conv

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Lions, Tigers, Bears"}
  end

  # CNK this is the original version, but changed to rewrite rule above 
  #     once we had a rewrite step in our overall pipeline
  # def route(%{method: "GET", path: "/bears/new"} = conv) do
  #   Path.expand("../../pages", __DIR__)
  #   |> Path.join("form.html")
  #   |> File.read()
  #   |> handle_file(conv)
  # end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | status: 204}
  end

  def route(%{method: "GET", path: path} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join(path <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def handle_file({:ok, contents}, conv) do
    %{conv | status: 200, resp_body: contents}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found."}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "ERROR: #{reason}"}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here."}
  end

  def emojify(%{status: 200} = conv) do
    body = "\u{1F60E}" <> " " <> conv.resp_body <> "\u{1F60E}" <> " "
    %{conv | resp_body: body}
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

IO.puts(response)
