function [] = tradestationwebapi()
% TRADESTATIONWEBAPI Access data from TradeStation

    APIKEY = '';
    APISECRET = '';
    BASEURL = 'https://sim.api.tradestation.com/v2/';
    CALLBACK = 'http://www.tradestation.com';
    
    [~,browser] = web(getAuthorizationUrl());
    
    % poll for the authorization code
    while(isempty(strfind(getCurrentLocation(browser),'code=')) == 1)
        pause(1);
    end

    code = getAuthorizationCodeFromUrl(getCurrentLocation(browser));
    close(browser);
    
    token = getTokenFromAuthorizationCode(code);
    disp('Getting access token');
    disp(token.access_token);
    
    disp('Getting msft quote');
    quote = getQuote('msft',token);
    disp(quote);
    
    disp('Getting access token from refresh token');
    token = getRefreshToken(token);
    disp(token.access_token);
    
    disp('Getting aapl quote');
    quote = getQuote('aapl',token);
    disp(quote);
    
    disp('Getting spy barchart stream');
    displayStreamingBarcharts('spy','1','Minute','10',token);
    
    function [url] = getAuthorizationUrl()
        url = strcat(BASEURL, ...
        sprintf( ...
        'authorize?client_id=%s&response_type=code&redirect_uri=%s' ...
        ,APIKEY,urlencode(CALLBACK)));
    end

    function [token] = getTokenFromAuthorizationCode(code)
        url = strcat(BASEURL,'security/authorize');
        body = ['grant_type=authorization_code&code=' code ...
            '&client_id=' APIKEY '&redirect_uri=' urlencode(CALLBACK) ...
            '&client_secret=' APISECRET];
        response = char(urlread2(url,'POST',body));
        token = loadjson(response);
    end

    function [token] = getRefreshToken(token)
        url = strcat(BASEURL,'security/authorize');
        body = ['grant_type=refresh_token&client_id=' APIKEY ...
            '&redirect_uri=' urlencode(CALLBACK) ...
            '&client_secret=' APISECRET ...
            '&refresh_token=' token.refresh_token];
        response = char(urlread2(url,'POST',body));
        token = loadjson(response);
    end

    function [quote] = getQuote(symbol,token)
        url = strcat(BASEURL,sprintf('data/quote/%s',symbol));
        params = {'oauth_token',token.access_token};
        queryString = http_paramsToString(params,1);
        url = [url '?' queryString];
        response = char(urlread2(url));
        quote = loadjson(response);
    end

    function [] = displayStreamingBarcharts(symbol,interval, ...
            intervaltype,barsback,token)
        import java.net.URL;
        import java.io.*;
        
        url = strcat(BASEURL,sprintf('stream/barchart/%s/%s/%s/%s', ...
            symbol,interval,intervaltype,barsback));
        params = {'oauth_token',token.access_token};
        queryString = http_paramsToString(params,1);
        theURL = URL([],[url '?' queryString], ...
            sun.net.www.protocol.https.Handler);
        
        % Open http connection:
        httpConn = theURL.openConnection;
        httpConn.setRequestProperty('Content-Type', ...
            'application/x-www-form-urlencoded');
        
        % open the connection:
        try
            inputStream = BufferedReader(InputStreamReader( ...
                httpConn.getInputStream));
        catch ME
            error(ME.message);
        end
        
        % start reading from the connection:
        sLine = inputStream.readLine;
        
        while (~isempty(sLine))
            if ~(sLine.isEmpty)
                % convert the response from json string to a MATLAB type.
                response = loadjson(char(sLine));
                disp(response);
            end
            sLine = inputStream.readLine;
        end
        
        % close the connection:
        inputStream.close;
    end
end

function [code] = getAuthorizationCodeFromUrl(url)
    url = char(url);
    code = strcat(url(strfind(url,'code=')+5:end),'=');
end