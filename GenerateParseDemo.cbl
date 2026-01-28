      $set nsymbol(national) display-picu(utf8)
       identification division.

       select items-file assign "items.json"
           organization is sequential.

       file section.
       fd items-file.
       01 json-str              pic x(1024).
       
       working-storage section.
       01 operation-flags       pic x.
         88 is-quit             values 'Q', 'q'.
         88 is-add              values 'A', 'a'.
         88 is-remove           values 'R', 'r'.
         88 is-edit             values 'E', 'e'.
         88 is-search           values 'S', 's'.
         88 is-dispall          values 'D', 'd'.

       01 item-information.
           03 num-of-items     binary-short value 0.
           03 items            occurs 25 depending on num-of-items.
               05 _name        pic x(32).
               05 description  pic x(128).
               05 price        pic 99v99.                                                                                      
               05 stock        binary-short.                                                                                       
               05 availability pic x.                                                                                      
                   88 for-sale values 'Y', 'y'.                                                                                     
                                                                                     
       01 search-information.                                                                                    
         03 search-name         pic x(32).                                                                                   
         03 search-desc         pic x(128).                                                                                      
         03 search-price        pic 99.99.                                                                                   
         03 search-stock        pic 9(5).                                                                                    
         03 search-availability pic x.                                                                                   
           88 for-sale          values 'Y', 'y'.                                                                                     
                                                                                     
       01 i                     binary-short.                                                                                    
       01 c1                    binary-short.                                                                                    
       01 item-index            binary-short.                                                                                    
       01 found-flags           pic x.                                                                                   
         88 item-found          values 'Y'.                                                                                      
                                                                                     
       01 edit-option           pic x.                                                                                   
         88 edit-name           value '1'.                                                                                   
         88 edit-desc           value '2'.                                                                                      
         88 edit-price          value '3'.
         88 edit-stock          value '4'.
         88 edit-availability   value '5'.
         88 quit                values 'Q', 'q'.
         
       procedure division.
           perform read-json-file
           display "Welcome to your store manager"
           display "HELLO WORLD"
           perform until is-quit
               perform display-menu
               evaluate true
                   when is-quit
                       perform write-and-quit
                   when is-add
                       perform add-record
                   when is-remove
                       perform remove-record
                   when is-edit
                       perform edit-record
                   when is-search
                       perform search-record
                       if item-found
                           perform display-searched-item
                       end-if
                       stop ">---Press Enter To Continue---<"
                   when is-dispall
                       perform display-all-records
                       stop ">---Press Enter To Continue---<"
           end-perform
       goback.

      *>----------------------------------------------------------------
      * Display Menu
      *
      * Displays the main menu options
      *>----------------------------------------------------------------

       display-menu section.
           display spaces upon crt
           display "Options: "
           display "        [A]dd Record"                
           display "        [R]emove Record"                
           display "        [E]dit Record"                
           display "        [S]earch Record"                
           display "        [D]isplay all records" 
           display "        [Q]uit"
           display "-<O>-: " no advancing
           accept operation-flags
           .

      *>----------------------------------------------------------------
      * Display Searched Item
      *
      * Displays the contents of the search-information data group in a
      * formatted manner. 
      *>----------------------------------------------------------------

       display-searched-item section.
           display ">---"
           display "Name:          " function trim(search-name)
           display "Description:   " function trim(search-desc)
           display "Price:         " search-price
           display "Stock:         " search-stock
           display "Available:     " search-availability
           .
       
      *>----------------------------------------------------------------
      * Display All Record
      *
      * Iterates throught the items array inside item-information and
      * displays a formatted version of the item using the display
      * searched item function.
      *>----------------------------------------------------------------

       display-all-records section.
           perform varying i from 0 by 1 until i = num-of-items
               move items[i] to search-information
               display "ITEM [" i "]"
               perform display-searched-item
           end-perform 
           .

      *>----------------------------------------------------------------
      * Add Record
      *
      * Adds a new record to the items array inside the item-inforamtion
      * data group and increases num-of-items by one. 
      *>----------------------------------------------------------------

       add-record section.
           if num-of-items equals 25
               display "maximum amount of items reached"
               goback
           end-if

           perform search-record
           if item-found
               display "Item of that name already exists"
           else
               move search-name to _name of items[num-of-items]
           
               display "Enter item description: " no advancing
               accept description of items[num-of-items]

               display "Enter item price: " no advancing
               accept price of items[num-of-items]

               display "Enter item stock: " no advancing
               accept stock of items[num-of-items]

               display "Is the item for sale? [Y/N]: " no advancing
               accept availability of items[num-of-items]

               add 1 to num-of-items
           end-if
           .
     
      *>----------------------------------------------------------------
      * Edit Record
      *
      * Uses search record to find an item, if found the user is then
      * given the option to edit each attribute of the item. When the
      * user presses 'Q' this quits the editing menu. 
      *>----------------------------------------------------------------

       edit-record section.
           perform search-record
           if item-found
               perform until quit
                   display spaces upon crt
                   display "Editing information for "
                       function trim(search-name)
                   display "Information to edit:"
                   display "   [1] Name"
                   display "   [2] Description"
                   display "   [3] Price"
                   display "   [4] Stock"
                   display "   [5] Availability"
                   display "   [Q]uit and save"
                   display "-<O>-: " no advancing
                   accept edit-option
               
                   evaluate true
                       when edit-name
                           display "Enter new name: " 
                               no advancing
                           accept _name of items[item-index]
                           display "Name edited"
                       when edit-desc
                           display "Enter new description: " 
                               no advancing
                           accept description of items[item-index]
                           display "Description edited"
                       when edit-price
                           display "Enter new price: " 
                                no advancing
                           accept price of items[item-index]
                           display "Price edited"
                       when edit-stock
                           display "Enter new stock count: " 
                               no advancing
                           accept stock of items[item-index]
                           display "Stock Count edited"
                       when edit-availability
                           display "Change availability: "
                               no advancing
                           accept availability of items[item-index]
                           display "Availability edited"
                   end-evaluate
               end-perform
               move spaces to edit-option
           end-if
           .

      *>----------------------------------------------------------------
      * Remove Record
      *
      * Uses search record to find an item and removes it from the array
      * all items are then shifted one to the left to fill the space. 
      * Once completed num-of-items is decreased by one.
      *>----------------------------------------------------------------

       remove-record section.
           perform search-record
           if item-found
               perform varying i from item-index by 1 
                   until i = num-of-items
                   if i + 1 <= 25
                       move items[i + 1] to items[i]
                   end-if 
               end-perform
           end-if
           subtract 1 from num-of-items
           .

      *>----------------------------------------------------------------
      * Search Record
      *
      * Iterates linearly through the items array inside the 
      * item-information data group and searches for a given data name
      * the function will then return the full item details in the
      * search item data group and the item index.
      *>----------------------------------------------------------------

       search-record section.
       initialize search-information
           display "Enter item name: " no advancing
           accept search-name
           
           move 'N' to found-flags
           perform varying i from 0 by 1 until i = num-of-items
               if _name of items[i] equals search-name
                   move description of items[i] to search-desc
                   move price of items[i] to search-price
                   move stock of items[i] to search-stock
                   move availability of items[i] to search-availability
                   move i to item-index
                   move 'Y' to found-flags
               end-if 
           end-perform
           if not item-found
               display "No item of that name"
           end-if
           .

      *>----------------------------------------------------------------
      * WRITE AND QUIT
      *
      * Generates a JSON string from the item-information data group and
      * writes it to a json file, once completed the program exits. 
      *>----------------------------------------------------------------

       write-and-quit section.
           display "Exiting...."
           *> Clear existing data     
           initialize json-str

           json generate json-str from item-information
               count in c1
               name of item-Information is 'itemInformation'            < This cbl program generates JSON to be read by Java Script                      
                       num-of-items is 'numOfItems'                       therefore we need to remove hyphens in variable names
                       _name is 'name'
               converting availability bool using for-sale of items
                     also description null using spaces
               on exception
                   exhibit named json-code
                   exhibit named json-status
           end-json

           open output items-file
           *> Write new data to file
           write json-str
           close items-file
           
           display spaces upon crt
           stop run
           .

      *>----------------------------------------------------------------
      * Read JSON File
      *
      * Opens the JSON file and parses the string stored inside it. The
      * data is parsed into item-information. 
      *>----------------------------------------------------------------

       read-json-file section.
           open input items-file
           read items-file
           json parse json-str into item-information
               with detail
               name of item-Information is 'itemInformation'
                       num-of-items is 'numOfItems'
                       _name is 'name'
               converting availability from bool using 'Y' and 'N'
                     also description from null using spaces
               on exception
                   exhibit named json-code
                   exhibit named json-status
           end-json
           close items-file
           .
           