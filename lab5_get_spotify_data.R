#load necessary packages
library(spotifyr) 
library(tidyverse)
library(here)

#get access token
#client secret and client ID safed to r environ file
#access and edit .renviron with usethis::edit_r_environ
access_token <- get_spotify_access_token(client_id = Sys.getenv("SPOTIFY_CLIENT_ID"),
                                         client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"))
### REQUEST DATA

#Get saved track list
offsets_list <- c(seq(0, 2900, 50)) #create list to get saved songs

saved_tracks_eb <- lapply(X = offsets_list,
                          FUN = get_my_saved_tracks, 
                          limit = 50
) |> #produce list of dfs for each call of 50
  bind_rows() #bind lists into one df

#Get saved track attributes
track_id_list <- saved_tracks_eb$track.id #create list of track ids

track_attributes_eb <- lapply(X = track_id_list,
                              FUN = get_track_audio_features) |> 
  bind_rows()

### WRANGLE DATA

#now append track list name to the track attributes df
saved_track_names <- saved_tracks_eb |> 
  select(track.name, track.id) |> #select out just track name and id
  rename(id = track.id) #rename id column to join

eb_tracks_df <- left_join(track_attributes_eb, saved_track_names, by = "id") #join df

#add user column
eb_tracks_df <- eb_tracks_df |> 
  add_column(user = "Erica")

#save dataframe as a csv to send to Jillian
write_csv(eb_tracks_df, here("eb_track_attributes.csv"))