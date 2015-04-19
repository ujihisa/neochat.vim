package main

import (
	"bufio"
	"encoding/json"
	"strconv"
	"strings"
	// "errors"
	"flag"
	"fmt"
	"github.com/mattn/go-lingr"
	"io/ioutil"
	"os"
	"sync"
	"time"
)

type Config struct {
	User     string `json:"user"`
	Password string `json:"password"`
	ApiKey   string `json:"apiKey"`
}

func makeClient(configFilename string) (*lingr.Client, error) {
	bytes, err := ioutil.ReadFile(configFilename)
	if err != nil {
		return nil, err
	}

	var config Config
	err = json.Unmarshal(bytes, &config)
	if err != nil {
		return nil, err
	}

	client := lingr.NewClient(config.User, config.Password, config.ApiKey)
	return client, nil
}

const LINE_SEPARATOR string = "---<gyoniku>---"

var (
	config = flag.String("config", "", "Configuration filepath.")
)

type Buffer struct {
	messages    map[string][]lingr.Message
	presences   map[string][]lingr.Presence
	memberships map[string][]lingr.Membership
	mutex       sync.Mutex
}

func handleInput(buffer *Buffer, client *lingr.Client) {
	in := bufio.NewReader(os.Stdin)
	for {
		line, _, err := in.ReadLine()
		if err != nil {
			panic(err)
		}
		items := strings.SplitN(string(line), ":", 2)
		var (
			cmd  string
			tail string
		)
		if len(items) >= 1 {
			cmd = items[0]
		}
		if len(items) >= 2 {
			tail = items[1]
		}
		if cmd == "say" {
			args := strings.SplitN(tail, ":", 2)
			if len(args) != 2 {
				panic("say:{room_id}:{message}")
			}
			err = client.Say(args[0], args[1])
			if err != nil {
				panic(err)
			}
		} else if cmd == "rooms" || cmd == "rooms!" {
			if cmd == "rooms!" {
				_, err = client.GetRooms()
				if err != nil {
					panic(err)
				}
			}
			for _, room := range client.RoomIds {
				fmt.Println(room)
			}
		} else if cmd == "fetch" {
			args := strings.SplitN(tail, ":", 2)
			if len(args) != 1 {
				panic("fetch:{room_id}")
			}
			buffer.mutex.Lock()
			var messages []lingr.Message
			if len(buffer.messages[args[0]]) < 30 {
				messages = buffer.messages[args[0]]
				buffer.messages[args[0]] = buffer.messages[args[0]][0:0]
			} else {
				messages = buffer.messages[args[0]][len(buffer.messages[args[0]])-30:]
				buffer.messages[args[0]] = buffer.messages[args[0]][:len(buffer.messages[args[0]])-30]
			}
			for _, message := range messages {
				fmt.Printf("{'id': '%s', 'room': '%s', 'text': '%s', 'nickname': '%s', 'speaker_id': '%s', 'timestamp': '%s', 'type': '%s', 'icon_url': '%s'}\n",
					message.Id,
					message.Room,
					message.Text,
					message.Nickname,
					message.SpeakerId,
					message.Timestamp,
					message.Type,
					message.IconUrl,
				)
			}
			buffer.mutex.Unlock()
		} else if cmd == "archive" {
			args := strings.SplitN(tail, ":", 3)
			if len(args) != 3 {
				panic("archive:{room_id}:{message_id}:{count}")
			}
			count, err := strconv.Atoi(args[2])
			if err != nil {
				panic(err)
			}
			messages, err := client.GetArchives(args[0], args[1], count)
			if err != nil {
				panic(err)
			}
			for _, message := range messages {
				fmt.Printf("{'id': '%s', 'room': '%s', 'text': '%s', 'nickname': '%s', 'speaker_id': '%s', 'timestamp': '%s', 'type': '%s', 'icon_url': '%s'}\n",
					message.Id,
					message.Room,
					message.Text,
					message.Nickname,
					message.SpeakerId,
					message.Timestamp,
					message.Type,
					message.IconUrl,
				)
			}
		} else {
			panic(fmt.Sprintf("Unknown command `%s'.", cmd))
		}
		// vital.ConcurrentProcess can't handle newline ended output
		// fmt.Println(LINE_SEPARATOR)
		fmt.Print(LINE_SEPARATOR)
	}
}

func main() {
	flag.Parse()

	if *config == "" {
		panic("Missing --config argument.")
	}

	client, err := makeClient(*config)
	if err != nil {
		panic(err)
	}

	buffer := &Buffer{
		messages:    make(map[string][]lingr.Message),
		presences:   make(map[string][]lingr.Presence),
		memberships: make(map[string][]lingr.Membership),
	}
	client.OnMessage = func(room lingr.Room, message lingr.Message) {
		buffer.mutex.Lock()
		defer buffer.mutex.Unlock()
		buffer.messages[room.Id] = append(buffer.messages[room.Id], message)
	}
	client.OnPresence = func(room lingr.Room, presence lingr.Presence) {
		buffer.mutex.Lock()
		defer buffer.mutex.Unlock()
		buffer.presences[room.Id] = append(buffer.presences[room.Id], presence)
	}
	client.OnMembership = func(room lingr.Room, membership lingr.Membership) {
		buffer.mutex.Lock()
		defer buffer.mutex.Unlock()
		buffer.memberships[room.Id] = append(buffer.memberships[room.Id], membership)
	}

	err = client.CreateSession()
	if err != nil {
		panic(err)
	}

	rooms, err := client.GetRooms()
	if err != nil {
		panic(err)
	}
	err = client.ShowRoom(strings.Join(rooms, ","))
	if err != nil {
		panic(err)
	}
	err = client.Subscribe(strings.Join(rooms, ","))
	if err != nil {
		panic(err)
	}

	// set initial messages
	buffer.mutex.Lock()
	for _, room := range client.Rooms {
		buffer.messages[room.Id] = room.Messages
	}
	buffer.mutex.Unlock()

	go handleInput(buffer, client)
	for {
		err = client.Observe()
		if err != nil {
			panic(err)
		}
		time.Sleep(2 * time.Second)
	}
}
