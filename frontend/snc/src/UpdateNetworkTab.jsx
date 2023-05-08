import React, { Component, useState } from 'react';
import { Button, Select, MenuItem, Box, Snackbar, Alert, List, ListItem, ListItemText, Dialog, DialogTitle, DialogContent, DialogActions} from '@mui/material';
import { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import UpdateIcon from '@mui/icons-material/Update';

const SNC_API_URL = process.env.REACT_APP_SNC_API_URL ? process.env.REACT_APP_SNC_API_URL : "/api/snc";

function fetchEsIndexes () {
    /*
    Makes a request to the back-end API to fetch existent ElasticSearch network indexes.
    */
    const url = SNC_API_URL + '/indexes';
    return new Promise((resolve, reject) => {
        fetch(url)
            .then((response) => response.json())
            .then((es_indexes) => {
                console.log(es_indexes);
                resolve(es_indexes);
            })
            .catch((err) => {
                console.log('Error: could not fetch ElasticSearch indexes');
                reject(err);
            })
    })
}

class UpdatedNetworkTab extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            esIndex: null,
            esIndexDescription: "",
            indexOptions: [],       // Query ES to retrieve indexes on page load
            readlogLoading: false,
            snackbarOpen: false,
            showLogDialog: false,
            snackbarMessage: '',
            snackbarSeverity: 'success',
            selectedFile: null,
            createdisable: false,
            deletedisable: false,
            logList: [],
        };
    }

    _handleReadLog = () => {
        console.log("Inside read log call");

        if (this.state.esIndex === null){
            this.setState({
                snackbarOpen: true,
                snackbarMessage: 'Index name is required to read log',
                snackbarSeverity: 'error',
            });
            return;
        }
        
        this.setState({
            readlogLoading: true
        });

        const requestOptions = {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ es_index_name: this.state.esIndex })
        };
        
        console.log("Calling getlog");
        const url = SNC_API_URL + '/getlog';
            fetch(url, requestOptions)
                .then((response) => {
                    if(response.status !== 200 || !response.ok)  {
                        // error
                        console.log("Inside error")
                        this._handleApiError();
                        this.setState({
                            readlogLoading: false
                        })
                    }                
                    else{
                        console.log("Got 200")
                        response.json().then(data => {
                            console.log(data);
                            this.setState({
                              snackbarOpen: true,
                              snackbarMessage: "Read Log Successful!",
                              snackbarSeverity: 'success',
                              readlogLoading: false,
                              logList: data,
                              showLogDialog: true
                            });
                          });
                    }
                })
                // .then(() => this.setState({
                //     updateLodaing: false, 
                //     disableDataField: false,
                //     disableNeo: false
                // }))
    };
          
    _updateUIControl = () => {
        // If all input is valid but construct btn disabled, enable it - otherwise disable it
        if(this.state.relations.length > 0 && this.state.userInput.length > 2 && this.state.esIndex != null) {
            this.setState({
                disableConstruct: false
            });
        } else {
            this.setState({
                disableConstruct: true
            });
        }
    }

    _handleTextFieldChange = (event) => {
        this.setState({
            userInput: event.target.value, 
        }, this._updateUIControl);
    }

    _handleApiError = () => {
        console.log("API ERROR!");
    }

    _handleDescription = (event) => {
        this.setState({esIndexDescription: event.target.value}, this._updateUIControl);
    }
        
    componentDidMount() {
        fetchEsIndexes()
            .then((es_indexes) => {
                this.setState({
                        indexOptions: es_indexes
                    });
            })
            .catch((err) => {
                console.log(err);
            })
    }

    render() {
        const filter = createFilterOptions();
        return (
            <Box
                sx={{
                    display: 'flex',
                    flexWrap: 'wrap'
                }}
            >
                <Box 
                    align="left" 
                    sx={{
                        width: '60%',
                        my: 2,
                        ml: 2,
                        // m: 1, 
                        '& .MuiTextField-root': { mt: 3, width: '90%'},
                    }}
                >

                    <Box
                        sx={{
                            display: 'flex',
                            flexWrap: 'wrap',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            width: '100%',
                            my: 2,
                            ml: 2,
                        }}
                    >
                        <Select
                            value={this.state.esIndex}
                            onChange={(event) => {
                                const newValue = event.target.value;
                                this.setState({esIndex: newValue, deletedisable: false, createdisable: true});
                            }}
                            id='es-index-selection'
                            sx={{width: '60%'}}
                            disabled={this.state.indexOptions.length === 0}
                            displayEmpty
                            renderValue={(value) => value || 'Select Desired Collection'}
                        >
                            <MenuItem value="" disabled>Select Desired Collection</MenuItem>
                            {this.state.indexOptions.map((option) => (
                                <MenuItem key={option} value={option}>{option}</MenuItem>
                            ))}
                        </Select>

                    </Box>

                    <Dialog open={this.state.showLogDialog} onClose={() => this.setState({ logList:[], showLogDialog: false })} maxWidth="md" fullWidth>
                        <DialogTitle>Log List</DialogTitle>
                        <DialogContent dividers>
                            <List dense>
                                {this.state.logList.map((log, index) => (
                                    <ListItem key={index}>
                                    <ListItemText primary={Object.keys(log).map(key => `${key}: ${log[key]}`).join(', ')} />
                                    </ListItem>
                                ))}
                            </List>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => this.setState({ logList:[], showLogDialog: false })}>Close</Button>
                        </DialogActions>
                    </Dialog>


                    <LoadingButton
                        variant="contained"
                        color="primary"
                        endIcon={<UpdateIcon />}
                        loading={this.state.readlogLoading}
                        loadingPosition="end"
                        onClick={this._handleReadLog}
                        sx={{my: 2, ml: 2}}
                        // sx={{ ml: "1em", mt: "1em" }}
                        size='small'
                    >
                        Update Collection Network
                    </LoadingButton>

                    <Snackbar
                        open={this.state.snackbarOpen}
                        autoHideDuration={3000}
                        onClose={() => this.setState({ snackbarOpen: false })}
                    >
                        <Alert
                            onClose={() => this.setState({ snackbarOpen: false })}
                            severity={this.state.snackbarSeverity}
                            sx={{ width: '100%' }}
                        >
                            {this.state.snackbarMessage}
                        </Alert>
                    </Snackbar>
                </Box>
            </Box>
        );
    }
}

export default UpdatedNetworkTab;