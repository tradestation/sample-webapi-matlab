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
end

function [code] = getAuthorizationCodeFromUrl(url)
    url = char(url);
    code = strcat(url(strfind(url,'code=')+5:end),'=');
end