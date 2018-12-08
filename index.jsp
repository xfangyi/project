<%@ page language="java" %>
<html>
        <head><title>Web-01</title></head>
        <body>
        <h1><font color="blue">Web-01.xfy.com</font></h1>
        <table align="centre" border="1">
        <tr>
        <td>Session ID</td>
        <% session.setAttribute("xfy.com","xfy.com"); %>
        <td><%= session.getId() %></td>
        </tr>
        <tr>
        <td>Created on</td>
        <td><%= session.getCreationTime() %></td>
        </tr>
        </table>
        </body>
</html>
