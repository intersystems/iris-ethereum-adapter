var winston = require('winston');
var path = require('path');

// Set this to whatever, by default the path of the script.
var logPath = __dirname;


const tsFormat = () => (new Date().toISOString());

var errorLog;
var accessLog;

var loggerErrorEnabled = false;
var loggerAccessEnabled = false;

const writeLog = function (jsonData, level) {
    switch (level) {
        case 'error':
            if (loggerErrorEnabled)
                errorLog.error({ message: jsonData });
            break;
        case 'info':
            if (loggerAccessEnabled)
                accessLog.info({ message: jsonData });
            break;
        default:
            return;
    }
}

const setLogger = function (level, pathToFile) {
    switch (level) {
        case 'error':
            if (!loggerErrorEnabled) {
                loggerErrorEnabled = true;
                errorLog = winston.createLogger({
                    transports: [
                        new winston.transports.File({
                            filename: path.join(logPath, pathToFile),
                            timestamp: tsFormat,
                            level: 'error'
                        })
                    ]
                });
            }
            break;
        case 'access':
            if (!loggerAccessEnabled) {
                loggerAccessEnabled = true;
                accessLog = winston.createLogger({
                    transports: [
                        new winston.transports.File({
                            filename: path.join(logPath, pathToFile),
                            timestamp: tsFormat,
                            level: 'info'
                        })
                    ]
                });
            }
            break;
    }
}

const disableLogger = function (level) {
    try {
        switch (level) {
            case 'error':
                loggerErrorEnabled = false;
                break;
            case 'access':
                loggerAccessEnabled = false;
                break;
        }
    }
    catch (err) {
    }
}

module.exports = {
    errorLog: errorLog,
    accessLog: accessLog,
    writeLog: writeLog,
    setLogger: setLogger,
    disableLogger: disableLogger
};