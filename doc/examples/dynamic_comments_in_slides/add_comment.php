<?php

/* get variables from the form */
$comment_file = $_GET['comment_file'];
$slide_url = $_GET['slide_url'];
$new_comment = $_GET['new_comment'];

/* change end of line into HTML end of line */
$new_comment = str_replace("\n", "<br />\n", $new_comment);

/* change escaped quotes into non-escaped */
$new_comment = str_replace("\'", "'", $new_comment);
$new_comment = str_replace('\"', '"', $new_comment);

/* open the comment file */
$fp = fopen ($comment_file, "a")
    or die ("Couldn't open the file to add comment for ".$slide_url."\n");

/* lock it to protect against concurrent accesses */
flock($fp, LOCK_EX);

/* Add the comment and format it */
fwrite($fp, "<b>New comment:</b><br />\n");
fwrite($fp, "<i>".$new_comment."</i>");
fwrite($fp, "<br />\n");

/* unlock and close the file */
flock($fp, LOCK_UN);
fclose ($fp);

/* go back to the slide */
header("Location: ".$slide_url);

?>
