import React from 'react';
import { Divider, Typography, AppBar, CssBaseline, Toolbar, Container, IconButton, Box } from '@mui/material';
import Grid from '@mui/material/Unstable_Grid2';
import HomeIcon from '@mui/icons-material/Home';

import UserInteractionField from './UserInteractionField';
import AboutField from './AboutField';

function NavBar(props) {
    return (
        <AppBar position="relative">
            <Toolbar>
                <IconButton aria-label={props.label} href={props.url} target="_blank">
                    <HomeIcon />
                </IconButton>
                <Typography ml={3} variant="h5" sx={{fontWeight: 'bold'}}>
                    {props.title}
                </Typography>
            </Toolbar>
        </AppBar>
    );
}

function Header(props) {
    return (
        <Container maxWidth="sm">
            <Typography variant="h2" align="center" color="textPrimary" gutterBottom sx={{whiteSpace: 'nowrap', fontSize: '2em'}}>
                Social Network Constructor
            </Typography>
            <Typography variant="h5" align="center" color="textSecondary" paragraph sx={{fontSize: '0.75em'}}>
                A tool for constructing social networks consisting of twitter users, tweets, organizations, persons, and many other entities. Simply provide either the base usernames or tweets and run this tool to visualize the data.
            </Typography>
        </Container>
    )
}

function App() { 
    return (
        <React.Fragment>
            <CssBaseline />
            <NavBar url="/" title="Workbench SNC" label="workbench home"/>

            <Box sx={{m: '2em'}}>
                <Header
                    title="Social Network Constructor" 
                    desc="A tool for constructing social networks consisting of twitter users, tweets, organizations, persons, and many other entities. Simply provide either the base usernames or tweets and run this tool to visualize the data."
                />
            </Box> 

            <Grid container sx={{m: 5}}>
                <Grid item xs>
                    <UserInteractionField />
                </Grid>

                <Divider orientation="vertical" flexItem sx={{borderRightWidth: 1.5}} />

                <Grid item xs>
                    <AboutField />
                </Grid>
            </Grid>
        </React.Fragment>
    );
}

export default App;

