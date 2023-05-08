import React, { Component, useState } from 'react';
import { TextField, Box, Snackbar, Alert} from '@mui/material';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import CreateIcon from '@mui/icons-material/Create';

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

class CreateCollectionTab extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            esIndex: null,
            esIndexDescription: "",
            indexOptions: [],       // Query ES to retrieve indexes on page load
            disableDescription: false,
            createLoading: false,
            snackbarOpen: false,
            showLogDialog: false,
            snackbarMessage: '',
            snackbarSeverity: 'success',
            createdisable: false,
            deletedisable: false,
            disableConstruct: true
        };
    }

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

    _handleRadioChange = (event) => {
        this.setState({timeframe: event.target.value});
    }

    _handleApiError = () => {
        console.log("API ERROR!");
    }

    _handleDescription = (event) => {
        this.setState({esIndexDescription: event.target.value});
    }
        
    _handleCreateIndexClick = () => {
        // Create index from elastic search (specified by this.state.esIndex)
        if(this.state.esIndex === '' || this.state.esIndex === null || this.state.indexOptions.indexOf(this.state.esIndex) !== -1) {
            if (this.state.indexOptions.indexOf(this.state.esIndex) !== -1){
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Collection Name Already Exist',
                    snackbarSeverity: 'error',
                });
            }
            else{
                this.setState({
                    snackbarOpen: true,
                    snackbarMessage: 'Index name is required to create a index',
                    snackbarSeverity: 'warning',
                });
            }
            return;
        }

        this.setState({
            createLoading: true
        })

        // Make API request to create specified index specified by this.state.esIndex
        const requestOptions = {
            method: 'PUT',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'index_name': this.state.esIndex,
                'description': this.state.esIndexDescription
            })
        };

        const url = SNC_API_URL + '/indexes/create';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'error',
                        });
                    });
                }
                else{
                    // console.log(response.json());
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'success',
                        });
                    });
                    let indexOptions_cpy = this.state.indexOptions;
                    indexOptions_cpy.push(this.state.esIndex);
                    this.setState({
                        indexOptions: indexOptions_cpy,
                        createdisable: true,
                        deletedisable: false,
                    });
                }
            })
            .then(() => {
                        this.setState({
                            createLoading: false
                        })})
        
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
                    flexWrap: 'wrap',
                    flexDirection: 'column',
                    my: 2,
                    ml: 2,
                }}
            >
                <Box 
                    align="left" 
                    sx={{ width: '70%', mt: 4, mb: 2, ml: 2}}
                >
                    <TextField
                        id="outlined-basic"
                        label="Collection Name"
                        variant="outlined"
                        placeholder="Enter Collection Name"
                        sx={{width: '70%'}}
                        value={this.state.esIndex}
                        onChange={(event) => {
                            this.setState({esIndex: event.target.value, createdisable: false})
                        }}
                    />
                </Box>
                <Box 
                    align="left" 
                    sx={{ width: '80%', my: 2, ml: 2}}
                >
                    <TextField
                        noValidate 
                        autoComplete="off" 
                        spellCheck="false" 
                        label="Collection Description" 
                        onChange={this._handleDescription}
                        placeholder="Enter Optional Description for the collection" 
                        disabled={this.state.disableDescription}
                        sx={{mb: '1em', width: '80%'}}
                        multiline 
                    />
                </Box>

                <Box 
                    align="left" 
                    sx={{ width: '60', my: 2, ml: 2}}
                >
                    <LoadingButton
                        onClick={this._handleCreateIndexClick}
                        endIcon={<CreateIcon />}
                        loading={this.state.createLoading}
                        loadingPosition='end'
                        variant='contained'
                        // sx={{mb: '1em'}}
                        disabled={this.state.createdisable}
                        size='small'
                    >
                        Create Collection
                    </LoadingButton>
                </Box>
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
        );
    }
}

export default CreateCollectionTab;