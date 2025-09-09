const http = require('http');

exports.handler = async (event) => {
    const backendUrl = "http://3.87.253.10:9900/"; // 后端服务地址

    try {
        const backendResponse = await makeHttpRequest(backendUrl);
        return {
            statusCode: 200,
            body: `OK ${backendResponse}`
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: `Fail ${error.message}`
        };
    }
};

// 使用原生 http 模块发送请求
const makeHttpRequest = (url) => {
    return new Promise((resolve, reject) => {
        const request = http.get(url, (response) => {
            let data = '';

            // 接收数据
            response.on('data', (chunk) => {
                data += chunk;
            });

            // 数据接收完成
            response.on('end', () => {
                if (response.statusCode >= 200 && response.statusCode < 300) {
                    resolve(data);
                } else {
                    reject(new Error(`HTTP ${response.statusCode}: ${data}`));
                }
            });
        });

        // 监听请求错误
        request.on('error', (error) => {
            reject(error);
        });

        // 结束请求
        request.end();
    });
};
