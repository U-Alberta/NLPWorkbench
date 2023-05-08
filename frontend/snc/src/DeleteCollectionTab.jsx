import React, { Component, useState } from 'react';
import { Select, MenuItem ,Box, Snackbar, Alert} from '@mui/material';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import LoadingButton from '@mui/lab/LoadingButton'
import DeleteIcon from '@mui/icons-material/Delete';

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

class DeleteCollectionTab extends Component {
    constructor(props) {
        super(props);
        this.state = {
            userInput: '', 
            esIndex: null,
            esIndexDescription: "",
            indexOptions: [],       // Query ES to retrieve indexes on page load
            disableDataField: false,
            deleteLoading: false,
            snackbarOpen: false,
            showLogDialog: false,
            snackbarMessage: '',
            snackbarSeverity: 'success',
            createdisable: false,
            deletedisable: false,
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

    _handleDeleteIndexClick = () => {
        // Deletes index from elastic search (specified by this.state.esIndex)
        if(this.state.esIndex === '' || this.state.esIndex === null) {
            this.setState({
                snackbarOpen: true,
                snackbarMessage: 'Collection name is required to delete a index',
                snackbarSeverity: 'error',
            });
            return;
        }

        if(this.state.indexOptions.indexOf(this.state.esIndex) === -1){
            this.setState({
                snackbarOpen: true,
                snackbarMessage: "Collection doesn't exist in collections",
                snackbarSeverity: 'error',
            });
            return;
        }

        this.setState({
            deleteLoading: true
        })

        // Make API request to delete specified index specified by this.state.esIndex
        const requestOptions = {
            method: 'DELETE',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                'index_name': this.state.esIndex
            })
        };

        const url = SNC_API_URL + '/indexes/delete';
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
                    })                    
                }
                else{
                    response.json().then(data => {
                        console.log(data);
                        this.setState({
                            snackbarOpen: true,
                            snackbarMessage: data,
                            snackbarSeverity: 'success',
                            deletedisable: true,
                        });
                        let indexOptions_cpy = this.state.indexOptions;
                        indexOptions_cpy.splice(indexOptions_cpy.indexOf(this.state.esIndex), 1);
                        this.setState({
                            indexOptions: indexOptions_cpy,
                            esIndex: null,
                            esIndexDescription: ""
                        })
                    })
                }
            })            
            .then(() => {
                this.setState({
                    deleteLoading: false
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
                            // my: 2,
                            mt: 4,
                            mb: 2,
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

                    {/* {selectedCollectionOption === delete_collection && */}
                    <LoadingButton
                        onClick={this._handleDeleteIndexClick}
                        endIcon={<DeleteIcon />}
                        loading={this.state.deleteLoading}
                        loadingPosition='end'
                        variant='contained'
                        // sx={{mb: '1em'}}
                        // sx={{mb: '1em'}}
                        sx={{my: 2, ml: 2}}
                        color='error'
                        disabled={this.state.deletedisable}
                        size='small'
                    >
                        Delete Collection
                    </LoadingButton>
                    {/* } */}

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

export default DeleteCollectionTab;