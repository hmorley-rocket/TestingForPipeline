async function main(){
    const response = await fetch('./items.json')
    let data = await response.json();
    displayItems(data.itemInformation);
}

function displayItems(itemInformation){
    const listItemTemplate = document.querySelector('#ListItem-Template');
    const listContainer = document.querySelector('#List-Container')
    for (const item of itemInformation.items){
        if (item.availability == true){
            const listItem = listItemTemplate.content.cloneNode(true);

            const body = listItem.querySelector('.ListItem');
            const itemName = listItem.querySelector('.itemName');
            const itemDesc = listItem.querySelector('.itemDesc');
            const itemPrice = listItem.querySelector('.itemPrice');
            const itemStock = listItem.querySelector('.itemStock');

            itemName.textContent = item.name;
            if (item.description == null){
                item.description = "No Description"
            }
            itemDesc.textContent = item.description;
            itemPrice.textContent = item.price;
            itemStock.textContent = item.stock;

            listContainer.append(listItem);
        }
    }
}

main();
