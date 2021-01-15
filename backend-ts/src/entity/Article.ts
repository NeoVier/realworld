import {
  AfterLoad,
  Column,
  CreateDateColumn,
  JoinTable,
  ManyToMany,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import Tag from "./Tag";
import User from "./User";

class Article {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  slug: string;

  @Column()
  description: string;

  @Column()
  body: string;

  @ManyToMany(() => Tag)
  @JoinTable()
  tagList: Tag[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.articles)
  author: User;

  @ManyToMany(() => User)
  @JoinTable()
  favorited: User[];

  favoriteCount: number;

  @AfterLoad()
  updateFavoriteCount() {
    this.favoriteCount = this.favorited.length;
  }
}

export default Article;
