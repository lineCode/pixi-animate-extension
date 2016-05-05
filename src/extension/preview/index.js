"use strict";

// Arguments: src, width, height, background, title
const argv = require('yargs').argv;
const menu = require('./menu');
const electron = require('electron');
const storage = require('electron-json-storage');
const app = electron.app;
const ipc = electron.ipcMain;
const Menu = electron.Menu;
const BrowserWindow = electron.BrowserWindow;

// Window to preview in
let mainWindow = null;

app.dock.hide();

// Quit when all windows are closed. 
app.on('window-all-closed', function() { 
    app.quit(); 
});

// This method will be called when Electron has finished 
// initialization and is ready to create browser windows. 
app.on('ready', function() {

    // The default settings
    let settings = {
        scaleToFit: true
    };

    mainWindow = new BrowserWindow({
        width: argv.width,
        height: argv.height,
        useContentSize: true,
        center: true,
        maximizable: false,
        minimizable: false,
        alwaysOnTop: true,
        skipTaskbar: true,
        show: false,
        title: argv.title || "Preview"
    });

    // Set the configuration
    ipc.on('config', function(event) {
        event.returnValue = {
            src: argv.src,
            height: argv.height,
            width: argv.width,
            background: argv.background || "fff"
        };
    });

    // Handle the window initialized
    ipc.on('init', function() {

        // Set the default window settings
        mainWindow.webContents.send('settings', settings);
        mainWindow.show();
    });

    storage.get('settings', function(err, data) {

        // Set the default settings if nothing is saved
        data = data || {};

        // Override the default settings
        Object.assign(settings, data);

        // Setup the menu
        let menuTemplate = menu(app, {
            toggleDevTools: function() {
                mainWindow.webContents.send('toggle-dev-tools');
            },
            reload: function() {
                mainWindow.webContents.clearHistory();
                mainWindow.webContents.send('reload');
            },
            actualSize: function() {
                mainWindow.setContentSize(argv.width, argv.height, true);
            },
            scaleToFit: function(item) {
                settings.scaleToFit = item.checked;
                storage.set('settings', settings);
                mainWindow.webContents.send('settings', settings);
            }
        }, {
            scaleToFit: settings.scaleToFit
        });

        // Set top-level application menu, using modified template
        Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));

        // Clear any local history
        mainWindow.webContents.clearHistory();

        if (argv.devTools) {
            mainWindow.webContents.toggleDevTools();
        }

        // Load the preview window
        mainWindow.loadURL('file://' + __dirname + '/preview.html'); 
        mainWindow.on('closed', function() { 
            mainWindow = null; 
        });
    });
});
