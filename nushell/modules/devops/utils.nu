
# Returns a datetime at midnight of the last business day
export def last-business-day [] {
    let today = (date now | format date "%A");
    if ($today == "Monday") {
        return ("last friday 00:00" | date from-human)
    }
    return ("yesterday 00:00" | date from-human)
}

# Parses the date string into a datetime or uses the last business day
export def parse-date-or-last-business-day [
    date?: string  # Date to parse or `null`
] {
    if $date == null {
        return (last-business-day)
    } else {
        return ($date | into datetime)
    }
}

# Partial match for strings in list
export def partial-match-in-list [
    matches?: list<string>  # Date to parse or `null`
]: string -> any {
    let input = $in | str lowercase;
    for $match in $matches {
        if ($input =~ ($match | str lowercase)) {
            return true;
        }
    }
    return false;
}
