package com.gb.et.others;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;

import com.gb.et.service.RequestLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Enumeration;
import java.util.stream.Collectors;

@Component
public class RequestLoggingFilter implements Filter {

    @Autowired
    private RequestLogService requestLogService;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpServletRequest = (HttpServletRequest) request;

        // Check if the URI matches the excluded API path
        String requestURI = httpServletRequest.getRequestURI();
        if(requestURI.contains("/file")){
        //if ("/api/vault/files".equals(requestURI) || "/api/file/upload".equals(requestURI)) {
            // Skip logging and continue the filter chain
            chain.doFilter(request, response);
            return;
        }

        // Wrap the request
        CachedBodyHttpServletRequestWrapper wrappedRequest = new CachedBodyHttpServletRequestWrapper(httpServletRequest);

        String method = wrappedRequest.getMethod();
        String url = wrappedRequest.getRequestURL().toString();

        // Collect headers
        String headers = "";
        Enumeration<String> headerNames = wrappedRequest.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            headers += headerName + ": " + wrappedRequest.getHeader(headerName) + "; ";
        }

        // Collect request body
        String body = "";
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method)) {
            body = new BufferedReader(wrappedRequest.getReader()).lines().collect(Collectors.joining("\n"));
        }

        // Log the request asynchronously
        requestLogService.logRequest(method, url, headers, body);

        // Continue the filter chain with the wrapped request
        chain.doFilter(wrappedRequest, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void destroy() {
    }
}

