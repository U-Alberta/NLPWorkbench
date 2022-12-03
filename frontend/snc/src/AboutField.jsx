import React from 'react';
import { Typography, Container, List, ListItem, ListItemIcon, ListItemText } from '@mui/material';
import GroupAddIcon from '@mui/icons-material/GroupAddRounded';
import CorporateFareIcon from '@mui/icons-material/CorporateFareRounded';
import HighlightIcon from '@mui/icons-material/HighlightRounded';
import QuizIcon from '@mui/icons-material/Quiz';

export default function AboutField(props) {
    return (
        <Container
            sx={{
                m: 1.5,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center'
            }}
        >
            <Typography fontSize='1.5em' fontWeight='bold' variant="h4">About</Typography>
            <Typography m={3}>
                This tool is part of the NLP Workbench. Here users are able to input either a set of twitter handles or tweet IDs in order to construct and
                visualize a social network of the provided entities. All the necessary data and metadata is pulled from <a target='_blank' rel='noreferrer' href='https://developer.twitter.com/en/docs/twitter-api'>Twitter's API</a> and formatted in order to
                be pushed to the graph database management system responsible for displaying all this data: <a target='_blank' rel='noreferrer' href='https://neo4j.com/docs/getting-started/current/'>
                Neo4j</a>. This in turn allows the user to not only visualize
                a subset of the data (and inspect areas of interest) but to also run graph algorithms to gain more insight behind certain networks (e.g. centrality
                algorithms). 
                <br /> <br />
                By building these graphs we are able to better answer questions such as: 
            </Typography>
            
            <List sx={{width: '100%', mt:-1}}>
                <ListItem>
                    <ListItemIcon>
                        <GroupAddIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="which users and/or tweets have the most interaction/connectivity"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <CorporateFareIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="which persons, organizations, global entities, etc. are mentioned in a given network (entity extraction from tweet embeddings)"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <HighlightIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="how do narratives and emphases shift given certain social networks (gauged by running centrality algorithms)"
                    />
                </ListItem>

                <ListItem>
                    <ListItemIcon>
                        <QuizIcon />
                    </ListItemIcon>
                    <ListItemText
                        primary="and many other similar questions which are difficult to answer efficiently simply by browsing tweets"
                    />
                </ListItem>
            </List>
        </Container>
    );
}