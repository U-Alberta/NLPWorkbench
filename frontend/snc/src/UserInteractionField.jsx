import React, { Component } from 'react';
import { Typography, TextField, Button, ToggleButton, ToggleButtonGroup, Box, Radio, RadioGroup, FormControlLabel, FormControl, FormLabel } from '@mui/material';
import LoadingButton from '@mui/lab/LoadingButton'
import ConstructionIcon from '@mui/icons-material/Construction';
import NorthEastIcon from '@mui/icons-material/NorthEast';

function TextDataField (props) {
    const placeholder = `Paste your ${props.placeholder} here`;
    return (
        <TextField 
            noValidate 
            autoComplete="off" 
            spellCheck="false" 
            label="Data" 
            onChange={props.onChange} 
            placeholder={placeholder} 
            disabled={props.disabled} 
            multiline
        />
    );
}

function CustomFormControlLabel (props) {
    return (
        <FormControlLabel 
            label={
                <Typography variant='overline'>{props.label}</Typography>
            }
            value={props.value}
            control={<Radio size='small' />}
        />
    );
}

function NeoButton (props) {
    if (props.disabled) {
        return (
            <Button 
                variant='outlined' 
                endIcon={<NorthEastIcon />} 
                sx={{mt: 1, ml: 2}}
                onClick={props.onClick}
                disabled
            >
                Open in Neo4j
            </Button>
        )
    } 
    return (
        <Button 
            variant='outlined' 
            endIcon={<NorthEastIcon />} 
            sx={{mt: 1, ml: 2}}
            onClick={props.onClick}
        >
            Open in Neo4j
        </Button>
    )
}

class UserInteractionField extends Component {
    constructor(props) {
        super(props);
        this.state = {
            data: '', 
            alignment: {
                value: 'users',
                description: 'Twitter handles'
            },
            constructDisabled: true,
            dataDisabled: false,
            neoDisabled: true,
            timeframe: 'week',
            loading: false
        };
    }

    _handleToggleButtonChange = (event, newAlignment) => {
        let desc;
        if(newAlignment === 'users') {
            desc = 'Twitter handles';                   // If user then handles must be provided
        } else {
            desc = 'Tweet IDs'                          // Otherwise tweets therefore tweet id's must be provided
        }
        this.setState({alignment: {
            value: newAlignment,
            description: desc
        }});
    }

    _handleTextFieldChange = (event) => {
        if(event.target.value.length > 1) {
            this.setState({data: event.target.value, constructDisabled: false});
        } else {
            this.setState({data: '', constructDisabled: true});
        }
    }

    _handleRadioChange = (event) => {
        this.setState({timeframe: event.target.value});
    }

    _handleApiError = () => {
        console.log("API ERROR!");
    }

    _handleConstructClick = () => {
        this.setState({loading: true, dataDisabled: true, neoDisabled: true});
        
        /* from wsgi.py in workbench back-end
        @app.route("/snc/run", methods=["POST"])
        def api_snc_run():
            data_type = request.json["type"]
            if data_type not in ("users", "tweets"):
                return "Invalid type", 400
            data = request.json["data"]
            if data is None or len(data) == 0:
                return "Invalid data", 400
            time_frame = request.json["time"]

            return flask_jsonify(api_impl.build_sn(data, type, time_frame))
        */
        // Call API and queue SNC task
        const requestOptions = {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                "data": this.state.data.split('\n'),
                "type": this.state.alignment.value,
                "time": this.state.timeframe
            })
        };

        const url = '/api/snc/run';
        fetch(url, requestOptions)
            .then((response) => {
                if(response.status !== 200 || !response.ok)  {
                    // error
                    this._handleApiError();
                }
            })
            .then(() => this.setState({loading: false, dataDisabled: false, neoDisabled: false}))
    }

    _handleNeoClick = () => {
        // Will redirect to neo4j browser (place-holder below for the time being)
        window.open('https://neo4j.com/docs/operations-manual/5/installation/neo4j-browser/', '_blank')
    }
    
    render() { 
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
                        m: 1, 
                        '& .MuiTextField-root': { mt: 3, width: '90%'},
                    }}
                >
                    <ToggleButtonGroup 
                        color='primary'
                        value={this.state.alignment.value} 
                        aria-label='data type' 
                        onChange={this._handleToggleButtonChange}
                        exclusive
                    >
                        <ToggleButton value='users'>Users</ToggleButton>
                        <ToggleButton value='tweets'>Tweets</ToggleButton>
                    </ToggleButtonGroup>

                    <FormControl size='small' sx={{ml: 6}}>
                        <FormLabel id='row-radio-time-frame' sx={{fontSize: '0.8em'}}>TIME FRAME</FormLabel>
                        <RadioGroup
                            row
                            name='row-radio-time-frame-buttons'
                            value={this.state.timeframe}
                            onChange={this._handleRadioChange}
                        >
                            <CustomFormControlLabel value='week' label='Week' />
                            <CustomFormControlLabel value='month' label='Month' />
                            <CustomFormControlLabel value='3month' label='3 Months' />
                            <CustomFormControlLabel value='other' label='Other' />
                        </RadioGroup>
                    </FormControl>

                    <TextDataField 
                        placeholder={this.state.alignment.description} 
                        disabled={this.state.dataDisabled} 
                        onChange={this._handleTextFieldChange} 
                    />

                    <LoadingButton
                        onClick={this._handleConstructClick}
                        endIcon={<ConstructionIcon />}
                        loading={this.state.loading}
                        loadingPosition='end'
                        variant='contained'
                        sx={{mt: 1}}
                        disabled={this.state.constructDisabled}
                    >
                        Construct Graph
                    </LoadingButton>

                    <NeoButton disabled={this.state.neoDisabled} onClick={this._handleNeoClick} />
                </Box>
            </Box>
        );
    }
}

export default UserInteractionField;